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
  setPlatform(const BrowserSeltzerHttp());
  setWebSocketProvider((String url) => new BrowserSeltzerWebSocket(url));
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
  String get payload => _request.responseText;
}

/// A [SeltzerWebSocket] implementation for the browser.
class BrowserSeltzerWebSocket implements SeltzerWebSocket {
  final Completer<Null> _onOpenCompleter = new Completer<Null>();
  final Completer<Null> _onCloseCompleter = new Completer<Null>();
  final StreamController<SeltzerMessage> _onMessageController =
      new StreamController<SeltzerMessage>.broadcast();

  StreamSubscription _dataSubscription;
  WebSocket _webSocket;

  /// Creates a new browser web sock connected to the remote peer at [url].
  BrowserSeltzerWebSocket(String url) {
    _webSocket = new WebSocket(url);
    _dataSubscription = _webSocket.onMessage.listen((MessageEvent event) async {
      _onMessageController.add(new _BrowserSeltzerMessage(event.data));
    });
    _webSocket.onOpen.first.then((_) {
      _onOpenCompleter.complete();
    });
    _webSocket.onClose.first.then((_) {
      _onCloseCompleter.complete();
    });
  }

  @override
  Stream<SeltzerMessage> get onMessage => _onMessageController.stream;

  @override
  Stream<Null> get onOpen => _onOpenCompleter.future.asStream();

  @override
  Stream<Null> get onClose => _onCloseCompleter.future.asStream();

  @override
  Future<Null> close([int code, String reason]) async {
    _errorIfClosed();
    _dataSubscription.cancel();
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
    if (_webSocket == null || _webSocket.readyState != WebSocket.OPEN) {
      throw new StateError("Socket is closed");
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
