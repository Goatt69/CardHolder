class PokeCard {
  PokeCard({
    required this.id,
    required this.cardSet,
    required this.series,
    required this.generation,
    required this.releaseDate,
    required this.name,
    required this.setNum,
    required this.types,
    required this.supertype,
    required this.hp,
    required this.evolvesfrom,
    required this.evolvesto,
    required this.rarity,
    required this.flavortext,
    required this.imageUrl,
  });

  final String? id;
  final String? cardSet;
  final String? series;
  final String? generation;
  final DateTime? releaseDate;
  final String? name;
  final String? setNum;
  final String? types;
  final String? supertype;
  final num? hp;
  final String? evolvesfrom;
  final String? evolvesto;
  final String? rarity;
  final String? flavortext;
  final String? imageUrl;

  factory PokeCard.fromJson(Map<String, dynamic> json){
    return PokeCard(
      id: json["id"],
      cardSet: json["set"],
      series: json["series"],
      generation: json["generation"],
      releaseDate: DateTime.tryParse(json["release_date"] ?? ""),
      name: json["name"],
      setNum: json["set_num"],
      types: json["types"],
      supertype: json["supertype"],
      hp: json["hp"],
      evolvesfrom: json["evolvesfrom"],
      evolvesto: json["evolvesto"],
      rarity: json["rarity"],
      flavortext: json["flavortext"],
      imageUrl: json["image_url"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "set": cardSet,
    "series": series,
    "generation": generation,
    "release_date": releaseDate?.toIso8601String(),
    "name": name,
    "set_num": setNum,
    "types": types,
    "supertype": supertype,
    "hp": hp,
    "evolvesfrom": evolvesfrom,
    "evolvesto": evolvesto,
    "rarity": rarity,
    "flavortext": flavortext,
    "image_url": imageUrl,
  };
}