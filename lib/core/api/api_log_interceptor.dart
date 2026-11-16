import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that prints formatted, easy-to-read logs for all network and mock API calls
/// strictly to the developer console/terminal (NOT on the UI).
class ApiLogInterceptor extends Interceptor {
  final bool enableConsolePrint;
  static const String _startTimeKey = '_req_start_time';

  ApiLogInterceptor({this.enableConsolePrint = kDebugMode});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    if (enableConsolePrint) {
      final buffer = StringBuffer();
      buffer.writeln('┌─────────────────────────────────────────────────────────────');
      buffer.writeln('🌐 [API REQ] [${options.method.toUpperCase()}] ${options.uri}');

      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('│ Query: ${options.queryParameters}');
      }

      final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
      if (sanitizedHeaders.containsKey('Authorization')) {
        final auth = sanitizedHeaders['Authorization'].toString();
        if (auth.length > 25) {
          sanitizedHeaders['Authorization'] =
              '${auth.substring(0, 15)}...${auth.substring(auth.length - 6)}';
        }
      }
      buffer.writeln('│ Headers: $sanitizedHeaders');

      if (options.data != null) {
        buffer.writeln('│ Body: ${_prettyPrintJson(options.data)}');
      }
      buffer.writeln('└─────────────────────────────────────────────────────────────');
      debugPrint(buffer.toString());
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra[_startTimeKey] as int?;
    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    if (enableConsolePrint) {
      final buffer = StringBuffer();
      buffer.writeln('┌─────────────────────────────────────────────────────────────');
      buffer.writeln(
          '✅ [API RES] [${response.statusCode}] (${duration}ms) [${response.requestOptions.method.toUpperCase()}] ${response.requestOptions.uri}');
      if (response.data != null) {
        final preview = _prettyPrintJson(response.data);
        buffer.writeln('│ Data: $preview');
      }
      buffer.writeln('└─────────────────────────────────────────────────────────────');
      debugPrint(buffer.toString());
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra[_startTimeKey] as int?;
    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : 0;

    if (enableConsolePrint) {
      final buffer = StringBuffer();
      buffer.writeln('┌─────────────────────────────────────────────────────────────');
      buffer.writeln(
          '❌ [API ERR] [${err.response?.statusCode ?? 'NO_STATUS'}] (${duration}ms) [${err.requestOptions.method.toUpperCase()}] ${err.requestOptions.uri}');
      buffer.writeln('│ Type: ${err.type}');
      buffer.writeln('│ Message: ${err.message}');
      if (err.response?.data != null) {
        buffer.writeln('│ Response: ${_prettyPrintJson(err.response?.data)}');
      }
      buffer.writeln('└─────────────────────────────────────────────────────────────');
      debugPrint(buffer.toString());
    }

    return handler.next(err);
  }

  String _prettyPrintJson(dynamic data) {
    try {
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        final formatted = encoder.convert(data);
        if (formatted.length > 800) {
          return '${formatted.substring(0, 800)}... [truncated]';
        }
        return formatted;
      }
      final str = data.toString();
      if (str.length > 500) {
        return '${str.substring(0, 500)}... [truncated]';
      }
      return str;
    } catch (_) {
      return data.toString();
    }
  }
}
