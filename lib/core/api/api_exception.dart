import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your internet connection.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        String errorMessage = 'Server returned an error ($status).';

        if (data is Map<String, dynamic>) {
          if (data.containsKey('message')) {
            errorMessage = data['message'].toString();
          } else if (data.containsKey('error')) {
            errorMessage = data['error'].toString();
          }
        }

        if (status == 401) {
          return ApiException(
            message: 'Session expired or invalid credentials. Please login again.',
            statusCode: status,
            details: data,
          );
        } else if (status == 403) {
          return ApiException(
            message: 'You do not have permission to perform this action.',
            statusCode: status,
            details: data,
          );
        } else if (status == 404) {
          return ApiException(
            message: 'Requested resource was not found.',
            statusCode: status,
            details: data,
          );
        } else if (status == 422) {
          return ApiException(
            message: errorMessage,
            statusCode: status,
            details: data,
          );
        }

        return ApiException(
          message: errorMessage,
          statusCode: status,
          details: data,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to connect to the server. Please check your network or server status.',
        );
      default:
        return ApiException(
          message: error.message ?? 'An unexpected network error occurred.',
        );
    }
  }

  @override
  String toString() => message;
}

