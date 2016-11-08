import 'dart:convert';

import 'package:meta/meta.dart';

/// A response sent by the `tool/echo/http.dart` binary.
class EchoHttpPayload {
  static EchoHttpPayload parse(List<int> payload) {
    final json = JSON.decode(UTF8.decode(payload));
    return new EchoHttpPayload(
      data: json['data'],
      headers: json['headers'] as Map<String, dynamic>,
      method: json['method'],
      url: json['url'],
    );
  }

  /// Data received via an HTTP request.
  final String data;

  /// Headers received via an HTTP request.
  final Map<String, dynamic> headers;

  /// HTTP method used.
  final String method;

  /// Url of the HTTP request.
  final String url;

  EchoHttpPayload({
    this.data: '',
    this.headers: const {},
    @required this.method,
    @required this.url,
  });

  /// Return as a JSON serializable object.
  toJson() => {'data': data, 'headers': headers, 'method': method, 'url': url};
}
