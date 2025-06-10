import 'dart:convert';
import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';

import '../app/constants.dart';

abstract class BaseRepository {
  final Dio dio;
  BaseRepository({required this.dio});

  Future<Map<String, dynamic>> postWoToken({
    required Map<String, dynamic> param,
    required String service,
    CancelToken? cancelToken,
  }) async {
    try {
      // dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
      Options dioOption = Options(
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
        contentType: "application/json",
      );

      final response = await dio.post(
        Constants.baseUrl + service,
        data: jsonEncode(param),
        options: dioOption,
        cancelToken: cancelToken,
      );
      if (response.statusCode != 200) {
        throw BaseRepositoryException(
          message: "Invalid Http Response ${response.statusCode}",
        );
      }
      Map<String, dynamic> jsonData = jsonDecode(response.data);
      if (jsonData["status"] != "OK") {
        throw BaseRepositoryException(
          message: jsonData["message"],
        );
      }
      return jsonData;
    } on DioError catch (e) {
      if (e.type != DioErrorType.cancel) {
        throw BaseRepositoryException(message: e.message);
      } else {
        throw BaseRepositoryException(message: "CancelToken");
      }
    } on SocketException catch (e) {
      throw BaseRepositoryException(message: e.message);
    } on BaseRepositoryException catch (e) {
      throw BaseRepositoryException(message: e.message);
    }
  }

  Future<Map<String, dynamic>> post({
    required Map<String, dynamic> param,
    required String service,
    required String token,
    CancelToken? cancelToken,
  }) async {
    try {
//      dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
      final response = await dio.post(
        Constants.baseUrl + service,
        data: jsonEncode(param),
        cancelToken: cancelToken,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $token",
          },
          contentType: "application/json",
        ),
      );

      if (response.statusCode != 200) {
        throw BaseRepositoryException(
          message: "Invalid Http Response ${response.statusCode}",
        );
      }
      Map<String, dynamic> jsonData = jsonDecode(response.data);
      if (jsonData["status"] != "OK") {
        throw BaseRepositoryException(
          message: jsonData["message"],
        );
      } else {
        return jsonData;
      }
    } on DioError catch (e) {
      throw BaseRepositoryException(message: e.message);
    } on SocketException catch (e) {
      throw BaseRepositoryException(message: e.message);
    } on BaseRepositoryException catch (e) {
      throw BaseRepositoryException(message: e.message);
    }
  }
}

class BaseRepositoryException implements Exception {
  final String message;
  BaseRepositoryException({
    required this.message,
  });
}
