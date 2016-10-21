import 'dart:async';
import 'dart:convert';
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
  String get payload => _request.responseText;
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
  Future<Null> get onClose => _webSocket.onClose.first.then((_) => null);

  @override
  Stream<SeltzerMessage> get onMessage {
    return _webSocket.onMessage.map((e) => new _BrowserSeltzerMessage(e.data));
  }

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

class _BrowserSeltzerMessage implements SeltzerMessage {
  final Object _payload;

  _BrowserSeltzerMessage(this._payload);

  @override
  Future<ByteBuffer> readAsArrayBuffer() async {
    if (_payload is String) {
      return new Uint8List.fromList(new Utf8Encoder().convert(_payload)).buffer;
    } else {
      // _payload must be a Blob.
      var fileReader = new FileReader()..readAsArrayBuffer(_payload);
      await fileReader.onLoadEnd.first;
      TypedData result = fileReader.result;
      return result.buffer;
    }
  }

  @override
  Future<String> readAsString() async => _payload.toString();
}
