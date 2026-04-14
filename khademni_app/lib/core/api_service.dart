import 'package:dio/dio.dart';
import 'storage.dart';
import 'constants.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: BASE_URL));

  static Future<void> init() async {
    final token = await Storage.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static Future<Response> get(String path) => _dio.get(path);
  static Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  static Future<Response> patch(String path, {dynamic data}) => _dio.patch(path, data: data);
}