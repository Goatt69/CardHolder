import 'Card.dart';
import 'TradeOffer.dart';
import 'UserModel.dart';

class PokePost {
  PokePost({
    required this.id,
    required this.posterId,
    required this.cardId,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.tradeOffers,
    required this.poster,
    required this.card,
  });

  final int? id;
  final String? posterId;
  final String? cardId;
  final String? description;
  final DateTime? createdAt;
  final num? status;
  final List<TradeOffer> tradeOffers;
  final User? poster;
  final Card? card;

  factory PokePost.fromJson(Map<String, dynamic> json){
    return PokePost(
      id: json["id"],
      posterId: json["posterId"],
      cardId: json["cardId"],
      description: json["description"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      status: json["status"],
      tradeOffers: json["tradeOffers"] == null ? [] : List<TradeOffer>.from(json["tradeOffers"]!.map((x) => TradeOffer.fromJson(x))),
      poster: json["poster"] == null ? null : User.fromJson(json["poster"]),
      card: json["card"] == null ? null : Card.fromJson(json["card"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "posterId": posterId,
    "cardId": cardId,
    "description": description,
    "createdAt": createdAt?.toIso8601String(),
    "status": status,
    "tradeOffers": tradeOffers.map((x) => x.toJson()).toList(),
    "poster": poster?.toJson(),
    "card": card?.toJson(),
  };

}

