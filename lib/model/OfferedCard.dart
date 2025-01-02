import 'Card.dart';

class OfferedCard {
  OfferedCard({
    required this.id,
    required this.tradeOfferId,
    required this.cardId,
    required this.tradeOffer,
    required this.card,
  });

  final int? id;
  final num? tradeOfferId;
  final String? cardId;
  final String? tradeOffer;
  final Card? card;

  factory OfferedCard.fromJson(Map<String, dynamic> json){
    return OfferedCard(
      id: json["id"],
      tradeOfferId: json["tradeOfferId"],
      cardId: json["cardId"],
      tradeOffer: json["tradeOffer"],
      card: json["card"] == null ? null : Card.fromJson(json["card"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "tradeOfferId": tradeOfferId,
    "cardId": cardId,
    "tradeOffer": tradeOffer,
    "card": card?.toJson(),
  };
}