import 'dart:convert';

/// Represents the full lifecycle and audit trace of an HTTP request.
class ApiLog {
  final String id;
  final DateTime timestamp;
  final String method;
  final String url;
  final Map<String, String> requestHeaders;
  final String? requestBody;
  
  final int? statusCode;
  final String? statusPhrase;
  final int? durationMs;
  final Map<String, String>? responseHeaders;
  final String? responseBody;
  final String? errorMessage;
  final bool isLoading;

  const ApiLog({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.url,
    required this.requestHeaders,
    this.requestBody,
    this.statusCode,
    this.statusPhrase,
    this.durationMs,
    this.responseHeaders,
    this.responseBody,
    this.errorMessage,
    this.isLoading = false,
  });

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isServerError => statusCode != null && statusCode! >= 500 && statusCode! < 600;
  bool get isError => isClientError || isServerError || errorMessage != null;

  String get statusCategory {
    if (isLoading) return 'In Flight (Pending)';
    if (statusCode == null) return 'Connection Error';
    if (isSuccess) return '2xx Success';
    if (statusCode! >= 300 && statusCode! < 400) return '3xx Redirection';
    if (isClientError) return '4xx Client Error';
    if (isServerError) return '5xx Server Error';
    return 'Unknown';
  }

  /// Educational description of what each HTTP code signifies.
  String get explanation {
    if (isLoading) return 'The HTTP request is currently in-flight awaiting the server response.';
    if (errorMessage != null && statusCode == null) {
      return 'Client failed to reach the server. Common causes: no internet, DNS resolution error, or request timeout.';
    }
    switch (statusCode) {
      case 200:
        return '200 OK: The request succeeded. The response payload contains the requested resource.';
      case 201:
        return '201 Created: The request succeeded and led to the creation of a new resource.';
      case 204:
        return '204 No Content: The request succeeded, but there is no representation to return.';
      case 400:
        return '400 Bad Request: The server cannot process the request due to client error (e.g., malformed syntax, invalid parameters).';
      case 401:
        return '401 Unauthorized: Authentication is required or invalid credentials were provided (missing or bad Bearer token).';
      case 403:
        return '403 Forbidden: The client is authenticated or recognized, but lacks permission or exceeded the rate limit.';
      case 404:
        return '404 Not Found: The server cannot find the requested resource or user.';
      case 429:
        return '429 Too Many Requests: Client sent too many requests in a given amount of time (rate limit exceeded).';
      case 500:
        return '500 Internal Server Error: The server encountered an unexpected condition that prevented it from fulfilling the request.';
      case 502:
        return '502 Bad Gateway: The server received an invalid response from the upstream server.';
      case 503:
        return '503 Service Unavailable: The server is currently unable to handle the request due to maintenance or overload.';
      default:
        return 'HTTP Status $statusCode received.';
    }
  }

  /// Helper to get formatted JSON if response body is valid JSON.
  String get formattedResponseBody {
    if (responseBody == null || responseBody!.trim().isEmpty) return '(empty response body)';
    try {
      final decoded = json.decode(responseBody!);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return responseBody!;
    }
  }

  ApiLog copyWith({
    String? id,
    DateTime? timestamp,
    String? method,
    String? url,
    Map<String, String>? requestHeaders,
    String? requestBody,
    int? statusCode,
    String? statusPhrase,
    int? durationMs,
    Map<String, String>? responseHeaders,
    String? responseBody,
    String? errorMessage,
    bool? isLoading,
  }) {
    return ApiLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      method: method ?? this.method,
      url: url ?? this.url,
      requestHeaders: requestHeaders ?? this.requestHeaders,
      requestBody: requestBody ?? this.requestBody,
      statusCode: statusCode ?? this.statusCode,
      statusPhrase: statusPhrase ?? this.statusPhrase,
      durationMs: durationMs ?? this.durationMs,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      responseBody: responseBody ?? this.responseBody,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
