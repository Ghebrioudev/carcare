import 'dart:convert';

import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.errors = const {},
  });

  final String message;
  final int? statusCode;
  final Map<String, List<String>> errors;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final parsed = _parseBody(response?.data);

    if (parsed != null) {
      return ApiException(
        message: _messageFromBody(parsed, statusCode),
        statusCode: statusCode,
        errors: _errorsFromBody(parsed),
      );
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Network error. Please check your connection and API URL.',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        message:
            'Server error ($statusCode). Check that migrations are up to date (php artisan migrate).',
        statusCode: statusCode,
      );
    }

    return ApiException(
      message: 'Unexpected server response.',
      statusCode: statusCode,
    );
  }

  factory ApiException.unexpectedResponse([int? statusCode]) {
    return ApiException(
      message: statusCode != null
          ? 'Unexpected server response (HTTP $statusCode).'
          : 'Unexpected server response.',
      statusCode: statusCode,
    );
  }

  static Map<String, dynamic>? _parseBody(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String _messageFromBody(Map<String, dynamic> body, int? statusCode) {
    final message = body['message']?.toString();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    if (statusCode == 401) {
      return 'Invalid credentials. Please try again.';
    }

    if (statusCode == 422) {
      return 'Validation failed. Please check your input.';
    }

    return 'Request failed.';
  }

  static Map<String, List<String>> _errorsFromBody(Map<String, dynamic> body) {
    final rawErrors = body['errors'];
    final parsedErrors = <String, List<String>>{};

    if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        if (value is List) {
          parsedErrors['$key'] = value.map((item) => '$item').toList();
        }
      });
    }

    return parsedErrors;
  }

  String? firstFieldError(String field) {
    final fieldErrors = errors[field];
    if (fieldErrors == null || fieldErrors.isEmpty) {
      return null;
    }
    return fieldErrors.first;
  }

  @override
  String toString() => message;
}
