import 'package:dio/dio.dart';
import 'package:flutter_pokemon/state/remote_state.dart';

const String imageUrl =
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/';

class DioApiClient {
  // Singleton
  static final DioApiClient _instance = DioApiClient._internal();
  factory DioApiClient() => _instance;

  late final Dio _dio;

  DioApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://pokeapi.co/api/v2',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
        responseType: ResponseType.json,
        receiveDataWhenStatusError: true,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _dioErrorHandler(error);
          return handler.next(error);
        },
      ),
    );
  }

  RemoteStateError _dioErrorHandler(DioException error) {
    return RemoteStateError(error.message ?? "Unknown Dio Error");
  }

  Dio get dio => _dio;
}
