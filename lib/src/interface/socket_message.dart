import 'dart:convert';

import 'http.dart';
import 'socket.dart';

/// A single message response by a [SeltzerWebSocket] or [SeltzerHttp] client.
class SeltzerMessage {
  final Encoding _encoding;
  final List<int> _bytes;
  final String _string;

  /// Create a new [SeltzerMessage] from string or binary data.
  factory SeltzerMessage(data) => data is String
      ? new SeltzerMessage.fromString(data)
      : new SeltzerMessage.fromBytes(data);

  /// Create a new [SeltzerMessage] from binary data.
  SeltzerMessage.fromBytes(this._bytes, {Encoding encoding: UTF8})
      : _encoding = encoding,
        _string = null;

  /// Create a new [SeltzerMessage] from text data.
  SeltzerMessage.fromString(this._string)
      : _encoding = null,
        _bytes = null;

  /// Returns as bytes representing the the message's payload.
  List<int> readAsBytes() {
    if (_string != null) {
      return _string.codeUnits;
    }
    return _bytes;
  }

  /// Returns a string representing this message's payload.
  String readAsString() {
    if (_string != null) {
      return _string;
    }
    return _encoding.decode(_bytes);
  }

  toJson() => _string ?? _bytes;
}
