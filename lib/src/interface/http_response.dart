import 'socket_message.dart';

/// An HTTP response object.
class SeltzerHttpResponse extends SeltzerMessage {
  /// HTTP response headers.
  final Map<String, String> headers;

  /// Create a new HTTP response from text or binary [data].
  factory SeltzerHttpResponse(
    data, {
    Map<String, String> headers: const {},
  }) =>
      data is String
          ? new SeltzerHttpResponse.fromString(data, headers: headers)
          : new SeltzerHttpResponse.fromBytes(data, headers: headers);

  /// Create a new HTTP response with binary data.
  SeltzerHttpResponse.fromBytes(
    List<int> bytes, {
    Map<String, String> headers: const {},
  })
      : this.headers = new Map<String, String>.unmodifiable(headers),
        super.fromBytes(bytes);

  /// Create a new HTTP response with text data.
  SeltzerHttpResponse.fromString(
    String string, {
    Map<String, String> headers: const {},
  })
      : this.headers = new Map<String, String>.unmodifiable(headers),
        super.fromString(string);

  toJson() {
    return {
      'data': super.toJson(),
      'headers': new Map<String, String>.from(headers),
    };
  }
}
