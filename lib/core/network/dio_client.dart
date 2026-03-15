import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient(this.dio) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }
}
