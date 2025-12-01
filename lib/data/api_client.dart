import 'package:http/http.dart' as http;

const String imageUrl =
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() {
    return _instance;
  }
  ApiClient._internal() {
    _client = http.Client();
  }

  final baseUrl = 'https://pokeapi.co/api/v2';

  late final http.Client _client;
  http.Client get client => _client;
}
