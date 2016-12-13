import 'dart:async';
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
class VmSeltzerHttp extends SeltzerHttp {
  /// Use the default VM implementation of [SeltzerHttp].
  @literal
  const factory VmSeltzerHttp() = VmSeltzerHttp._;

  const VmSeltzerHttp._();

  @override
  Stream<SeltzerHttpResponse> handle(SeltzerHttpRequest request,
      [Object data]) {
    return new HttpClient()
        .openUrl(request.method, Uri.parse(request.url))
        .then((r) async {
      request.headers.forEach(r.headers.add);
      final response = await r.close();
      final payload = await response.first;
      final headers = <String, String>{};
      response.headers.forEach((name, value) {
        headers[name] = value.join(' ');
      });
      if (payload is String) {
        return new SeltzerHttpResponse.fromString(payload, headers: headers);
      } else {
        return new SeltzerHttpResponse.fromBytes(payload, headers: headers);
      }
    }).asStream();
  }
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
    return new SeltzerMessage.fromBytes(payload.asUint8List());
  }
  if (payload is TypedData) {
    return new SeltzerMessage.fromBytes(payload.buffer.asUint8List());
  }
  return new SeltzerMessage.fromString(payload);
}
