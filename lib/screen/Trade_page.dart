import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/config_url.dart';
import '../services/pokepost_service.dart';
import '../services/collection_card_service.dart';
import '../model/PokePost.dart';
import '../model/PokeCard.dart';

class TrandePage extends StatefulWidget {
  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TrandePage> {
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
    
    final selectedCards = await showDialog<List<PokeCard>>(
      context: context,
      builder: (context) => SelectCardsDialog(cards: cards),
    );

    if (selectedCards != null && selectedCards.isNotEmpty) {
      try {
        await _pokePostService.createTradeOffer(
          post.id!,
          selectedCards.map((c) => c.id!).toList(),
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
      appBar: AppBar(
        title: Text('Trade Posts'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreatePostDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    child: ListTile(
                      // In the ListView.builder
                      leading: Image.network(
                        '${Config_URL.imageUrl}/cards/${post.card?.id}/${post.card?.setNum}.jpg',
                        errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Text('Image not available')),
                      ),
                      title: Text(post.card?.name ?? 'Unknown Card'),
                      subtitle: Text(post.description ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () => _createTradeOffer(post),
                        child: Text('Trade'),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _showCreatePostDialog() async {
    final cards = await _collectionService.getUserCards();
    final selectedCard = await showDialog<PokeCard>(
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
          await _pokePostService.createPost(selectedCard.id!, description);
          _loadPosts();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create post: $e'))
          );
        }
      }
    }
  }
}

// Additional helper dialogs
class SelectCardsDialog extends StatefulWidget {
  final List<PokeCard> cards;
  SelectCardsDialog({required this.cards});

  @override
  _SelectCardsDialogState createState() => _SelectCardsDialogState();
}

class _SelectCardsDialogState extends State<SelectCardsDialog> {
  List<PokeCard> selectedCards = [];
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Cards to Offer'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: widget.cards.length,
          itemBuilder: (context, index) {
            final card = widget.cards[index];
            return CheckboxListTile(
              title: Text(card.name ?? ''),
              value: selectedCards.contains(card),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedCards.add(card);
                  } else {
                    selectedCards.remove(card);
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
  final List<PokeCard> cards;
  SelectCardDialog({required this.cards});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select a Card to Trade'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return ListTile(
              title: Text(card.name ?? ''),
              onTap: () => Navigator.pop(context, card),
            );
          },
        ),
      ),
    );
  }
}

class DescriptionDialog extends StatefulWidget {
  @override
  _DescriptionDialogState createState() => _DescriptionDialogState();
}

class _DescriptionDialogState extends State<DescriptionDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Description'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Enter trade description',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text('Create'),
        ),
      ],
    );
  }
}