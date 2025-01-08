import 'package:cardholder/model/PokeCard.dart';
import 'package:cardholder/services/api_client.dart';
import 'package:cardholder/services/card_service.dart';
import 'package:flutter/material.dart';
import '../config/config_url.dart';
import '../model/PokePost.dart';
import '../model/TradeOffer.dart';
import '../model/UserModel.dart';
import '../services/auth_service.dart';
import '../services/pokepost_service.dart';

class TradeOffersDialog extends StatefulWidget {
  final PokePost post;

  TradeOffersDialog({required this.post});

  @override
  _TradeOffersDialogState createState() => _TradeOffersDialogState();
}
class _TradeOffersDialogState extends State<TradeOffersDialog> {
  User? _currentUser;
  final PokePostService _pokePostService = PokePostService();
  final AuthService _authService = AuthService();
  final ApiService _pokeCardService = ApiService();
  List<PokeCard> cards = [];
  
  @override
  void initState() {
    super.initState();
    fetchCards();
    _loadCurrentUser();
  }
  Future<void> fetchCards() async {
    try {
      final fetchedCards = await _pokeCardService.fetchCards();
      
      setState(() {
        cards = fetchedCards;
      });
    } catch (e) {
      print('Error fetching cards: $e');
    }
  }
  
  Future<void> _loadCurrentUser() async {
    final userInfo = await _authService.userInfo();
    if (userInfo['success']) {
      setState(() {
        _currentUser = User.fromJson(userInfo['user']);
        print("Current User ID: ${_currentUser?.id}");
        print("Post Owner ID: ${widget.post.posterId}");
      });
    }
  }

  Future<void> _acceptOffer(BuildContext context, TradeOffer offer) async {
    try {
      await _pokePostService.acceptTradeOffer(offer.id!);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trade offer accepted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept trade offer: $e')),
      );
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Trade Offers for ${widget.post.card?.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.post.tradeOffers.length,
                itemBuilder: (context, index) {
                  final offer = widget.post.tradeOffers[index];
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Offered by: ${offer.trader?.userName}'),
                          SizedBox(height: 8),
                          Text('Offered Cards:'),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: offer.offeredCards.length,
                              itemBuilder: (context, cardIndex) {
                                final offeredCard = offer.offeredCards[cardIndex];
                                final card = cards.where((card) => card.id == offeredCard.cardId).toList();
                                if (card.isNotEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Image.network(
                                      '${Config_URL.imageUrl}/cards/${offeredCard.cardId}/${card[0].setNum}.jpg',
                                      width: 80,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 80,
                                          color: Colors.grey,
                                          child: Center(
                                            child: Text('No image'),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return Container(
                                    width: 80,
                                    color: Colors.grey,
                                    child: Center(
                                      child: CircularProgressIndicator()
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          if (widget.post.posterId == _currentUser?.id)
                            IconButton(
                              onPressed: offer.status == 0
                                  ? () => _acceptOffer(context, offer)
                                  : null,
                              icon: Icon(Icons.handshake),
                              color: offer.status == 0 ? Colors.lightBlue : Colors.grey,
                              tooltip: offer.status == 0 ? 'Accept Offer' : 'Offer ${offer.status}',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
