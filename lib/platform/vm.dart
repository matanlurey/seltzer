import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:seltzer/src/context.dart';
import 'package:seltzer/src/interface.dart';

export 'package:seltzer/seltzer.dart';

/// Initializes `package:seltzer/seltzer.dart` to use [VmSeltzerHttp].
///
/// This is appropriate for clients running in the VM on the command line.
void useSeltzerInVm() {
  setHttpPlatform(const VmSeltzerHttp());
  setSocketPlatform(VmSeltzerWebSocket.connect);
}

/// An implementation of [SeltzerHttp] implemented via the Dart VM.
///
/// Worsk in the Dart VM on the command line or AoT compiled in Flutter.
class VmSeltzerHttp extends PlatformSeltzerHttp {
  /// Use the default VM implementation of [SeltzerHttp].
  @literal
  const factory VmSeltzerHttp() = VmSeltzerHttp._;

  const VmSeltzerHttp._();

  @override
  Future<SeltzerHttpResponse> execute(
    String method,
    String url, {
    Map<String, String> headers,
  }) async {
    var request = await new HttpClient().openUrl(method, Uri.parse(url));
    headers.forEach(request.headers.add);
    var response = await request.close();
    var payload = await response.first;
    var responseHeaders = <String, String>{};
    response.headers
        .forEach((name, value) => responseHeaders[name] = value.join(' '));
    return new _VmSeltzerHttpResponse(
      payload,
      request.encoding,
      new Map<String, String>.unmodifiable(responseHeaders),
    );
  }
}

class _VmSeltzerHttpResponse implements SeltzerHttpResponse {
  @override
  final Map<String, String> headers;

  final Encoding _encoding;

  final List<int> _payload;

  _VmSeltzerHttpResponse(this._payload, this._encoding, this.headers);

  @override
  List<int> readAsBytes() => new List<int>.unmodifiable(_payload);

  @override
  String readAsString() => _encoding.decode(_payload);
}

/// A [SeltzerWebSocket] implementation for the Dart VM.
class VmSeltzerWebSocket implements SeltzerWebSocket {
  /// Connects via web socket to [url].
  static Future<VmSeltzerWebSocket> connect(String url) async {
    return new VmSeltzerWebSocket._(
      await WebSocket.connect(url),
      new Completer<SeltzerSocketClosedEvent>.sync(),
    );
  }

  final Completer<SeltzerSocketClosedEvent> _onCloseCompleter;
  final WebSocket _webSocket;

  VmSeltzerWebSocket._(
    WebSocket webSocket,
    Completer<SeltzerSocketClosedEvent> onCloseCompleter,
  )
      : onMessage =
            webSocket.asBroadcastStream().asyncMap(_decodeSocketMessage),
        _webSocket = webSocket,
        _onCloseCompleter = onCloseCompleter {
    onMessage.isEmpty.then((_) {
      if (webSocket.readyState == WebSocket.CLOSED) {
        _triggerOnClose();
      } else {
        webSocket.done.then((_) => _triggerOnClose());
      }
    });
  }

  void _triggerOnClose() {
    _onCloseCompleter.complete(
      new SeltzerSocketClosedEvent(
        _webSocket.closeCode,
        _webSocket.closeReason,
      ),
    );
  }

  @override
  final Stream<SeltzerMessage> onMessage;

  @override
  Future<SeltzerSocketClosedEvent> get onClose => _onCloseCompleter.future;

  @override
  Future<Null> close({int code, String reason}) async {
    _errorIfClosed();
    _webSocket.close(code, reason);
  }

  @override
  Future<Null> sendString(String data) async {
    _errorIfClosed();
    _webSocket.add(data);
  }

  @override
  Future<Null> sendBytes(ByteBuffer data) async {
    _errorIfClosed();
    _webSocket.add(data.asInt8List());
  }

  void _errorIfClosed() {
    if (_webSocket.readyState != WebSocket.OPEN) {
      throw new StateError('Socket is closed.');
    }
  }
}

Future<SeltzerMessage> _decodeSocketMessage(payload) async {
  if (payload is ByteBuffer) {
    return new PlatformSeltzerBinaryMessage(payload.asUint8List());
  }
  if (payload is TypedData) {
    return new PlatformSeltzerBinaryMessage(payload.buffer.asUint8List());
  }
  return new PlatformSeltzerTextMessage(payload);
}
