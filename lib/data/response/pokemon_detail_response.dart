import 'dart:convert';

PokemonDetailResponse pokemonDetailResponseFromJson(String str) =>
    PokemonDetailResponse.fromJson(json.decode(str));

String pokemonDetailResponseToJson(PokemonDetailResponse data) =>
    json.encode(data.toJson());

class PokemonDetailResponse {
  String name;
  int id;
  int height;
  int weight;
  List<TypeElement> types;

  PokemonDetailResponse({
    required this.name,
    required this.id,
    required this.height,
    required this.weight,
    required this.types,
  });

  factory PokemonDetailResponse.fromJson(Map<String, dynamic> json) =>
      PokemonDetailResponse(
        name: json["name"],
        id: json["id"],
        height: json["height"],
        weight: json["weight"],
        types: List<TypeElement>.from(
          json["types"].map((x) => TypeElement.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "id": id,
    "height": height,
    "weight": weight,
    "types": List<dynamic>.from(types.map((x) => x.toJson())),
  };
}

class TypeElement {
  TypeType type;

  TypeElement({required this.type});

  factory TypeElement.fromJson(Map<String, dynamic> json) =>
      TypeElement(type: TypeType.fromJson(json["type"]));

  Map<String, dynamic> toJson() => {"type": type.toJson()};
}

class TypeType {
  String name;

  TypeType({required this.name});

  factory TypeType.fromJson(Map<String, dynamic> json) =>
      TypeType(name: json["name"]);

  Map<String, dynamic> toJson() => {"name": name};
}
