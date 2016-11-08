import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:seltzer/src/context.dart';
import 'package:seltzer/src/interface.dart';

export 'package:seltzer/seltzer.dart';

/// Initializes `package:seltzer/seltzer.dart` to use [BrowserSeltzerHttp].
///
/// This is appropriate for clients running in Dartium, DDC, and dart2js.
void useSeltzerInTheBrowser() {
  setHttpPlatform(const BrowserSeltzerHttp());
  setSocketPlatform(BrowserSeltzerWebSocket.connect);
}

/// An implementation of [SeltzerHttp] that works within the browser.
///
/// The "browser" means support for Dartium, DDC, and dart2js.
class BrowserSeltzerHttp extends PlatformSeltzerHttp {
  /// Use the default browser implementation of [SeltzerHttp].
  @literal
  const factory BrowserSeltzerHttp() = BrowserSeltzerHttp._;

  const BrowserSeltzerHttp._();

  @override
  Future<SeltzerHttpResponse> execute(
    String method,
    String url, {
    Map<String, String> headers: const {},
  }) async {
    return new _HtmlSeltzerHttpResponse(await HttpRequest.request(
      url,
      method: method,
      requestHeaders: headers,
    ));
  }
}

class _HtmlSeltzerHttpResponse implements SeltzerHttpResponse {
  final HttpRequest _request;

  _HtmlSeltzerHttpResponse(this._request);

  @override
  Map<String, String> get headers => _request.responseHeaders;

  @override
  List<int> readAsBytes() => new List<int>.unmodifiable(_request.response);

  @override
  String readAsString() => _request.responseText;
}

/// A [SeltzerWebSocket] implementation for the browser.
class BrowserSeltzerWebSocket implements SeltzerWebSocket {
  /// Connects via web socket to [url].
  static Future<BrowserSeltzerWebSocket> connect(String url) async {
    final socket = new WebSocket(url);
    await socket.onOpen.first;
    return new BrowserSeltzerWebSocket._(
      socket,
    );
  }

  final WebSocket _webSocket;

  BrowserSeltzerWebSocket._(this._webSocket);

  @override
  Future<SeltzerSocketClosedEvent> get onClose async {
    final event = await _webSocket.onClose.first;
    return new SeltzerSocketClosedEvent(
      event.code,
      event.reason,
    );
  }

  @override
  Stream<SeltzerMessage> get onMessage => _webSocket.onMessage.asyncMap((e) {
        return _decodeSocketMessage(e.data);
      });

  @override
  Future<Null> close({int code, String reason}) async {
    _errorIfClosed();
    _webSocket.close(code, reason);
  }

  @override
  Future<Null> sendString(String data) async {
    _errorIfClosed();
    _webSocket.sendString(data);
  }

  @override
  Future<Null> sendBytes(ByteBuffer data) async {
    _errorIfClosed();
    _webSocket.sendTypedData(data.asInt8List());
  }

  void _errorIfClosed() {
    if (_webSocket?.readyState != WebSocket.OPEN) {
      throw new StateError('Socket is closed.');
    }
  }
}

Future<SeltzerMessage> _decodeSocketMessage(payload) async {
  if (payload is String) {
    return new PlatformSeltzerTextMessage(payload);
  } else {
    final reader = new FileReader()..readAsArrayBuffer(payload);
    await reader.onLoadEnd.first;
    return new PlatformSeltzerBinaryMessage(reader.result);
  }
}
