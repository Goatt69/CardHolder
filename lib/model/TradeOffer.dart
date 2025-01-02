import 'OfferedCard.dart';
import 'UserModel.dart';

class TradeOffer {
  TradeOffer({
    required this.id,
    required this.postId,
    required this.traderId,
    required this.offerDate,
    required this.status,
    required this.offeredCards,
    required this.trader,
    required this.post,
  });

  final int? id;
  final num? postId;
  final String? traderId;
  final DateTime? offerDate;
  final num? status;
  final List<OfferedCard> offeredCards;
  final User? trader;
  final String? post;

  factory TradeOffer.fromJson(Map<String, dynamic> json){
    return TradeOffer(
      id: json["id"],
      postId: json["postId"],
      traderId: json["traderId"],
      offerDate: DateTime.tryParse(json["offerDate"] ?? ""),
      status: json["status"],
      offeredCards: json["offeredCards"] == null ? [] : List<OfferedCard>.from(json["offeredCards"]!.map((x) => OfferedCard.fromJson(x))),
      trader: json["trader"] == null ? null : User.fromJson(json["trader"]),
      post: json["post"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "postId": postId,
    "traderId": traderId,
    "offerDate": offerDate?.toIso8601String(),
    "status": status,
    "offeredCards": offeredCards.map((x) => x.toJson()).toList(),
    "trader": trader?.toJson(),
    "post": post,
  };

}