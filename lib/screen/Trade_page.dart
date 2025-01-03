import 'package:flutter/material.dart';
import '../config/config_url.dart';
import '../services/pokepost_service.dart';
import '../services/collection_card_service.dart';
import '../model/PokePost.dart';
import '../model/CardHolder.dart';
import '../widget/DescriptionDialog.dart';

class TradePage extends StatefulWidget {
  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  final PokePostService _pokePostService = PokePostService();
  final CollectionCardService _collectionService = CollectionCardService();
  List<PokePost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _pokePostService.getAllPosts();
      setState(() {
        _posts = posts;
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
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                        '${Config_URL.imageUrl}/cards/${post.card?.id}/${post.card?.setNum}.jpg',
                        errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Text('Image not available')),
                      ),
                      title: Text(post.card?.name ?? 'Unknown Card'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.description ?? ''),
                          Text('Posted by: ${post.poster?.userName ?? 'Unknown'}'),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _createTradeOffer(post),
                        child: Text('Trade'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                        ),
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
