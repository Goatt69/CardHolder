import 'PokeCard.dart';
import 'UserModel.dart';

class CardHolder {
  CardHolder({
    required this.id,
    required this.userId,
    required this.cardId,
    required this.quantity,
    required this.user,
    required this.card,
  });

  final int? id;
  final String? userId;
  final String? cardId;
  final num? quantity;
  final User? user;
  final PokeCard? card;

  factory CardHolder.fromJson(Map<String, dynamic> json){
    return CardHolder(
      id: json["id"],
      userId: json["userId"],
      cardId: json["cardId"],
      quantity: json["quantity"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      card: json["card"] == null ? null : PokeCard.fromJson(json["card"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "cardId": cardId,
    "quantity": quantity,
    "user": user?.toJson(),
    "card": card?.toJson(),
  };

}