import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:seltzer/src/context.dart' as platform;

/// Returns a connected [SeltzerWebSocket] to [url].
typedef Future<SeltzerWebSocket> SeltzerWebSocketProvider(String url);

/// A cross-platform [web socket](https://tools.ietf.org/html/rfc6455).
///
/// The socket must be opened before any data can be sent through it.  Clients
/// should close the socket when they are finished listening to its [onMessage]
/// stream.
///
/// ## Example Usage:
///     var socket = await SeltzerWebSocket.connect('ws://foo.com:9090');
///     socket.onMessage.listen(print);
///     await socket.sendString(stringData);
///     await socket.close();
abstract class SeltzerWebSocket {
  /// Connects to a web socket server at [url].
  ///
  /// Returns a [Future] that completes upon connecting.
  static Future<SeltzerWebSocket> connect(String url) => platform.connect(url);

  /// The stream of data received by this socket.
  Stream<SeltzerMessage> get onMessage;

  /// An future that completes when the socket is closed.
  Future<SeltzerSocketClosedEvent> get onClose;

  /// Initiates closing this socket's connection.
  ///
  /// The returned future completes when all open close messages have been sent
  /// and all subscriptions have cancelled.  To determine when the socket itself
  /// truly closes, wait until [onClose] completes.
  ///
  /// Set the optional [code] and [reason] arguments to send close information
  /// to the remote peer.
  Future<Null> close({int code, String reason});

  /// Sends bytes [data] to the remote peer.
  Future<Null> sendBytes(ByteBuffer data);

  /// Sends string [data] to the remote peer.
  Future<Null> sendString(String data);
}

/// Returned from [SeltzerWebSocket.onClose].
class SeltzerSocketClosedEvent {
  /// Code defining why the socket closed.
  final int code;

  /// Message why the socket closed.
  final String reason;

  const SeltzerSocketClosedEvent(this.code, [this.reason]);
}

/// An [SeltzerWebSocket] that delegates to an existing instance.
///
/// Suitable for wrapping existing implementation and overriding some details.
class SeltzerWebSocketTransformer implements SeltzerWebSocket {
  final SeltzerWebSocket _delegate;

  /// Default constructor.
  SeltzerWebSocketTransformer(this._delegate);

  @override
  Stream<SeltzerMessage> get onMessage => _delegate.onMessage;

  @override
  Future<SeltzerSocketClosedEvent> get onClose => _delegate.onClose;

  @override
  Future<Null> close({int code, String reason}) =>
      _delegate.close(code: code, reason: reason);

  @override
  Future<Null> sendString(String data) => _delegate.sendString(data);

  @override
  Future<Null> sendBytes(ByteBuffer data) => _delegate.sendBytes(data);
}

/// Elegant and rich cross-platform HTTP service.
///
/// See `platform/browser.dart` and `platform/vm.dart` for implementations.
abstract class SeltzerHttp {
  /// Returns the platform-initialized [SeltzerHttp] instance.
  ///
  /// Throws [StateError] if an implementation was not yet chosen.
  factory SeltzerHttp() => platform.getPlatform();

  /// Create a request to DELETE from [url].
  SeltzerHttpRequest delete(String url);

  /// Create a request to GET to [url].
  SeltzerHttpRequest get(String url);

  /// Create a request to PATCH to [url].
  SeltzerHttpRequest patch(String url);

  /// Create a request to POST to [url].
  SeltzerHttpRequest post(String url);

  /// Create a request to PUT to [url].
  SeltzerHttpRequest put(String url);
}

/// A partial implementation of [SeltzerHttp] without platform specific details.
abstract class PlatformSeltzerHttp implements SeltzerHttp {
  /// Allows sub-classes to be const.
  const PlatformSeltzerHttp();

  /// Executes with a standard input of arguments for an HTTP request.
  ///
  /// Returns a [Stream] of [SeltzerHttpResponse] objects.
  Future<SeltzerHttpResponse> execute(
    String method,
    String url, {
    Map<String, String> headers,
  });

  @override
  @mustCallSuper
  SeltzerHttpRequest delete(String url) => request('DELETE', url);

  @override
  @mustCallSuper
  SeltzerHttpRequest get(String url) => request('GET', url);

  @override
  @mustCallSuper
  SeltzerHttpRequest patch(String url) => request('PATCH', url);

  @override
  @mustCallSuper
  SeltzerHttpRequest post(String url) => request('POST', url);

  @override
  @mustCallSuper
  SeltzerHttpRequest put(String url) => request('PUT', url);

  /// Handles all HTTP [method] requests to [url].
  @protected
  SeltzerHttpRequest request(String method, String url) =>
      new PlatformSeltzerHttpRequest(
        this,
        method: method,
        url: url,
      );
}

/// An implementation of [SeltzerHttp] that delegates to an existing instance.
///
/// Suitable for wrapping existing implementation and overriding some details.
class SeltzerHttpTransformer implements SeltzerHttp {
  final SeltzerHttp _delegate;

  /// Default constructor.
  SeltzerHttpTransformer(this._delegate);

  @override
  SeltzerHttpRequest get(String url) => _delegate.get(url);

  @override
  SeltzerHttpRequest post(String url) => _delegate.post(url);

  @override
  SeltzerHttpRequest put(String url) => _delegate.put(url);

  @override
  SeltzerHttpRequest delete(String url) => _delegate.delete(url);

  @override
  SeltzerHttpRequest patch(String url) => _delegate.patch(url);
}

/// An HTTP request object.
///
/// Use [SeltzerHttpRequest.send] to receive a [Stream] interface.
///
/// In most simple use cases [Stream.first] will connect and return a value:
///     get('some/url.json').send().first.then((value) => print('Got: $value'));
///
/// Some implementations of [SeltzerHttp] may choose to allow multiple responses
/// and/or respond with a local cache first, and then make a response against
/// the server. In that case, [Stream.listen] may be preferred:
///     get('some/url.json').send().listen((value) => print('Got: $value'));
abstract class SeltzerHttpRequest {
  /// Sets [value] as an HTTP [header].
  ///
  /// Returns a new instance of [SeltzerHttpRequest] with the value added.
  SeltzerHttpRequest set(String header, String value);

  /// HTTP headers.
  Map<String, String> get headers;

  /// HTTP method to use.
  String get method;

  /// URL to send the request to.
  String get url;

  /// Makes the HTTP request, and returns a [Stream] of results.
  Stream<SeltzerHttpResponse> send();
}

/// A partial implementation of [SeltzerHttpRequest] without platform specifics.
class PlatformSeltzerHttpRequest implements SeltzerHttpRequest {
  final PlatformSeltzerHttp _executor;

  @override
  final Map<String, String> headers;

  @override
  final String method;

  @override
  final String url;

  /// Initialize a new [PlatformSeltzerHttpRequest].
  PlatformSeltzerHttpRequest(
    this._executor, {
    this.headers: const {},
    @required this.method,
    @required this.url,
  });

  @override
  Stream<SeltzerHttpResponse> send() {
    return _executor
        .execute(
          method,
          url,
          headers: headers,
        )
        .asStream();
  }

  @override
  PlatformSeltzerHttpRequest set(String header, String value) {
    var headers = new Map<String, String>.from(this.headers);
    headers[header] = value;
    return new PlatformSeltzerHttpRequest(
      _executor,
      headers: new Map<String, String>.unmodifiable(headers),
      method: method,
      url: url,
    );
  }
}

/// A message received by a [SeltzerWebSocket] or [SeltzerHttp] client.
abstract class SeltzerMessage {
  /// Returns as bytes representing the the message's payload.
  List<int> readAsBytes();

  /// Returns a string representing this message's payload.
  String readAsString();
}

class PlatformSeltzerBinaryMessage implements SeltzerMessage {
  final List<int> _payload;

  PlatformSeltzerBinaryMessage(this._payload);

  @override
  List<int> readAsBytes() => new List<int>.unmodifiable(_payload);

  @override
  String readAsString() => UTF8.decode(_payload);
}

class PlatformSeltzerTextMessage implements SeltzerMessage {
  final String _payload;

  PlatformSeltzerTextMessage(this._payload);

  @override
  List<int> readAsBytes() => _payload.codeUnits;

  @override
  String readAsString() => _payload;
}

/// An HTTP response object.
abstract class SeltzerHttpResponse implements SeltzerMessage {
  /// HTTP response headers.
  Map<String, String> get headers;
}
