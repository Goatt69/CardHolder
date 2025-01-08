import 'package:flutter/material.dart';
import '../config/config_url.dart';
import '../model/UserModel.dart';
import '../services/auth_service.dart';
import '../services/pokepost_service.dart';
import '../services/collection_card_service.dart';
import '../model/PokePost.dart';
import '../model/CardHolder.dart';
import '../widget/DescriptionDialog.dart';
import '../widget/TradeOffersDialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class TradePage extends StatefulWidget {
  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  User? _currentUser;
  final PokePostService _pokePostService = PokePostService();
  final AuthService _authService = AuthService();
  final CollectionCardService _collectionService = CollectionCardService();
  List<PokePost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadCurrentUser();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _pokePostService.getAllPosts();
      setState(() {
        _posts = posts.where((post) => post.status != 2).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load posts: $e'))
      );
    }
  }


  Future<void> _createTradeOffer(PokePost post) async {
    final cards = await _collectionService.getUserCards();

    final selectedCards = await showDialog<List<CardHolder>>(
      context: context,
      builder: (context) => SelectCardsDialog(cards: cards),
    );

    if (selectedCards != null && selectedCards.isNotEmpty) {
      try {
        await _pokePostService.createTradeOffer(
          post.id!,
          selectedCards.map((c) => c.cardId!).toList(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Trade offer created successfully!'))
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create trade offer: $e'))
        );
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    final userInfo = await _authService.userInfo();
    if (userInfo['success']) {
      setState(() {
        _currentUser = User.fromJson(userInfo['user']);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: 100,
            child: Center(
              child: Text(
                'Trade Posts',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _loadPosts,
              child: GridView.builder(
                padding: EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  // Skip posts with status 2
                  if (post.status == 2) {
                    return Container(); // Returns an empty container for status 2
                  }
                  return Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () => _showTradeOffersDialog(post),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Image.network(
                              '${Config_URL.imageUrl}/cards/${post.card?.id}/${post.card?.setNum}.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Text('Image not available')),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.card?.name ?? 'Unknown Card',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'By: ${post.poster?.userName ?? 'Unknown'}',
                                        style: TextStyle(fontSize: 8),
                                      ),
                                      SizedBox(
                                        height: 20, // Chiều cao của marquee
                                        child: shadcn.OverflowMarquee
                                          (
                                          child:
                                          Text( post.description ?? 'No description',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),

                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (post.posterId != _currentUser?.id)
                                  IconButton(
                                    onPressed: () => _createTradeOffer(post),
                                    icon: Icon(Icons.swap_horiz),
                                    color: Colors.lightBlue,
                                    tooltip: 'Trade',
                                  ),
                              ],
                            ),
                          )

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.lightBlue,
      ),
    );
  }
  void _showTradeOffersDialog(PokePost post) {
    showDialog(
      context: context,
      builder: (context) => TradeOffersDialog(post: post),
    );
  }
  Future<void> _showCreatePostDialog() async {
    final cards = await _collectionService.getUserCards();
    final selectedCard = await showDialog<CardHolder>(
      context: context,
      builder: (context) => SelectCardDialog(cards: cards),
    );

    if (selectedCard != null) {
      final description = await showDialog<String>(
        context: context,
        builder: (context) => DescriptionDialog(),
      );

      if (description != null) {
        try {
          await _pokePostService.createPost(selectedCard.cardId!, description);
          await _loadPosts();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create post: $e'))
          );
        }
      }
    }
  }
}

class SelectCardsDialog extends StatefulWidget {
  final List<CardHolder> cards;
  SelectCardsDialog({required this.cards});

  @override
  _SelectCardsDialogState createState() => _SelectCardsDialogState();
}

class _SelectCardsDialogState extends State<SelectCardsDialog> {
  List<CardHolder> selectedCards = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Cards to Offer'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: widget.cards.length,
          itemBuilder: (context, index) {
            final cardHolder = widget.cards[index];
            return CheckboxListTile(
              title: Text(cardHolder.card?.name ?? ''),
              subtitle: Text('Quantity: ${cardHolder.quantity}'),
              value: selectedCards.contains(cardHolder),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedCards.add(cardHolder);
                  } else {
                    selectedCards.remove(cardHolder);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedCards),
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
class SelectCardDialog extends StatelessWidget {
  final List<CardHolder> cards;
  SelectCardDialog({required this.cards});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select a Card to Trade'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final cardHolder = cards[index];
            return ListTile(
              leading: Image.network(
                '${Config_URL.imageUrl}/cards/${cardHolder.card?.id}/${cardHolder.card?.setNum}.jpg',
                width: 50,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported),
              ),
              title: Text(cardHolder.card?.name ?? ''),
              subtitle: Text('Quantity: ${cardHolder.quantity}'),
              onTap: () => Navigator.pop(context, cardHolder),
            );
          },
        ),
      ),
    );
  }
}
