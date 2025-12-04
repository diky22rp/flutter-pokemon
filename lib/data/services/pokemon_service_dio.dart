import 'package:dio/dio.dart';
import 'package:flutter_pokemon/data/dio_api_client.dart';
import 'package:flutter_pokemon/data/response/pokemon_detail_response.dart';
import 'package:flutter_pokemon/data/response/pokemon_list_response.dart';
import 'package:flutter_pokemon/state/remote_state.dart';

class PokemonServiceDio {
  final dio = DioApiClient().dio;

  Future<RemoteState<PokemonListResponse>> fetchPokemons({
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get('/pokemon?offset=$offset&limit=$limit');

      return RemoteStateSuccess(PokemonListResponse.fromJson(response.data));
    } on DioException catch (e) {
      return RemoteStateError("Dio Error: ${e.message}");
    } catch (e) {
      return RemoteStateError("Unexpected Error: $e");
    }
  }

  Future<RemoteState<PokemonDetailResponse>> fetchPokemonDetail(int id) async {
    try {
      final response = await dio.get('/pokemon/$id');

      return RemoteStateSuccess(PokemonDetailResponse.fromJson(response.data));
    } on DioException catch (e) {
      return RemoteStateError("Dio Error: ${e.message}");
    } catch (e) {
      return RemoteStateError("Unexpected Error: $e");
    }
  }
}
