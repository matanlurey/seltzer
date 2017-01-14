import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'http.dart';
import 'socket.dart';

/// A single message response by a [SeltzerWebSocket] or [SeltzerHttp] client.
class SeltzerMessage {
  final Encoding _encoding;
  final int _length;
  final Stream<List<int>> _bytes;

  String _string;

  /// Create a new [SeltzerMessage] from string or binary data.
  factory SeltzerMessage(data) => data is String
      ? new SeltzerMessage.fromString(data)
      : new SeltzerMessage.fromBytes(data as Stream<List<int>>);

  /// Create a new [SeltzerMessage] from binary data.
  SeltzerMessage.fromBytes(this._bytes, {int length, Encoding encoding: UTF8})
      : _encoding = encoding,
        _length = length,
        _string = null;

  /// Create a new [SeltzerMessage] from text data.
  SeltzerMessage.fromString(this._string)
      : _encoding = null,
        _length = null,
        _bytes = null;

  /// Returns as a stream of bytes representing the message's payload.
  ///
  /// Some responses may be streamed into multiple chunks, which means that
  /// listening to `stream.first` is not enough. To read the entire chunk in a
  /// single call, use [readAsBytesAll].
  Stream<List<int>> readAsBytes() => _bytes ?? readAsBytesAll().asStream();

  /// Returns bytes representing the message's payload.
  Future<List<int>> readAsBytesAll() async {
    if (_bytes == null) {
      return _string.codeUnits;
    }
    var offset = 0;
    return _bytes.fold/*<List<int>>*/(
      new Uint8List(_length),
      (buffer, value) {
        buffer.setRange(offset, value.length, value);
        offset += value.length;
      },
    );
  }

  /// Returns a string representing this message's payload.
  Future<String> readAsString() async {
    return _string ??= await _encoding.decodeStream(_bytes);
  }

  toJson() => _string ?? _bytes;
}
