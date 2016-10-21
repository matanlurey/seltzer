import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:seltzer/src/context.dart';
import 'package:seltzer/src/interface.dart';

export 'package:seltzer/seltzer.dart';

/// Initializes `package:seltzer/seltzer.dart` to use [ServerSeltzerHttp].
///
/// This is appropriate for clients running in the VM on the command line.
void useSeltzerInTheServer() {
  setHttpPlatform(const ServerSeltzerHttp());
  setSocketPlatform(ServerSeltzerWebSocket.connect);
}

/// An implementation of [SeltzerHttp] that works within the browser.
///
/// The "server" means in the Dart VM on the command line.
class ServerSeltzerHttp extends PlatformSeltzerHttp {
  /// Use the default server implementation of [SeltzerHttp].
  @literal
  const factory ServerSeltzerHttp() = ServerSeltzerHttp._;

  const ServerSeltzerHttp._();

  @override
  Future<SeltzerHttpResponse> execute(
    String method,
    String url, {
    Map<String, String> headers,
  }) async {
    var request = await new HttpClient().openUrl(method, Uri.parse(url));
    headers.forEach(request.headers.add);
    var response = await request.close();
    var payload = await UTF8.decodeStream(response);
    return new _IOSeltzerHttpResponse(payload);
  }
}

class _IOSeltzerHttpResponse implements SeltzerHttpResponse {
  @override
  final String payload;

  _IOSeltzerHttpResponse(this.payload);
}

/// A [SeltzerWebSocket] implementation for the dart vm.
class ServerSeltzerWebSocket implements SeltzerWebSocket {
  /// Connects via web socket to [url].
  static Future<ServerSeltzerWebSocket> connect(String url) async {
    return new ServerSeltzerWebSocket._(
      await WebSocket.connect(url),
      new Completer<Null>.sync(),
    );
  }

  final Completer<Null> _onCloseCompleter;
  final WebSocket _webSocket;

  ServerSeltzerWebSocket._(
    WebSocket webSocket,
    Completer<Null> onCloseCompleter,
  )
      : onMessage = webSocket
            .asBroadcastStream()
            .map((p) => new _ServerSeltzerMessage(p)),
        _webSocket = webSocket,
        _onCloseCompleter = onCloseCompleter {
    onMessage.isEmpty.then((_) {
      if (webSocket.readyState == WebSocket.CLOSED) {
        onCloseCompleter.complete();
      } else {
        onMessage.last.then((_) => onCloseCompleter.complete());
      }
    });
  }

  @override
  final Stream<SeltzerMessage> onMessage;

  @override
  Future<Null> get onClose => _onCloseCompleter.future;

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

class _ServerSeltzerMessage implements SeltzerMessage {
  final Object _payload;

  _ServerSeltzerMessage(this._payload);

  @override
  Future<ByteBuffer> readAsArrayBuffer() async {
    if (_payload is ByteBuffer) {
      return _payload;
    } else if (_payload is TypedData) {
      TypedData data = _payload;
      return data.buffer;
    } else {
      // _payload must be String.
      return new Uint8List.fromList(new Utf8Encoder().convert(_payload)).buffer;
    }
  }

  @override
  Future<String> readAsString() async => _payload.toString();
}
