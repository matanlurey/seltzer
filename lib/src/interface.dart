import 'dart:async';

import 'package:meta/meta.dart';
import 'package:seltzer/src/context.dart';

/// Elegant and rich cross-platform HTTP service.
///
/// See `platform/browser.dart` and `platform/server.dart` for implementations.
abstract class SeltzerHttp {
  /// Returns the platform-initialized [SeltzerHttp] instance.
  ///
  /// Throws [StateError] if an implementation was not yet chosen.
  factory SeltzerHttp() => getPlatform();

  /// Create a request to GET to [url].
  SeltzerHttpRequest get(String url);

  /// Create a request to POST to [url].
  SeltzerHttpRequest post(String url);
}

/// A partial implementation of [SeltzerHttp] without platform specific details.
abstract class PlatformSeltzerHttp implements SeltzerHttp {
  /// Allows sub-classes to be const.
  const PlatformSeltzerHttp();

  @override
  @mustCallSuper
  SeltzerHttpRequest get(String url) => request('GET', url);

  @override
  @mustCallSuper
  SeltzerHttpRequest post(String url) => request('POST', url);

  /// Handles all HTTP [method] requests to [url].
  @protected
  SeltzerHttpRequest request(String method, String url);
}

/// An implementation of [SeltzerHttp] that delegates to an existing instance.
///
/// Suitable for wrapping existing implementation and overriding some details.
class SeltzerHttpTransformer implements SeltzerHttp {
  final SeltzerHttp _delegate;

  SeltzerHttpTransformer(this._delegate);

  @override
  SeltzerHttpRequest get(String url) => _delegate.get(url);

  @override
  SeltzerHttpRequest post(String url) => _delegate.post(url);
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
  /// Adds [value] to an HTTP [header].
  ///
  /// Returns a new instance of [SeltzerHttpRequest] with the value added.
  SeltzerHttpRequest addHeader(String header, String value);

  /// HTTP headers.
  Map<String, List<String>> get headers;

  /// HTTP method to use.
  String get method;

  /// URL to send the request to.
  String get url;

  /// Makes the HTTP request, and returns a [Stream] of results.
  Stream<SeltzerHttpResponse> send();
}

/// A partial implementation of [SeltzerHttpRequest] without platform specifics.
abstract class PlatformSeltzerHttpRequest implements SeltzerHttpRequest {
  @override
  final Map<String, List<String>> headers;

  @override
  final String method;

  @override
  final String url;

  /// Initialize a new [PlatformSeltzerHttpRequest].
  PlatformSeltzerHttpRequest({
    this.headers: const {},
    @required this.method,
    @required this.url,
  });

  @override
  SeltzerHttpRequest addHeader(String header, String value) {
    var map = new Map<String, List<String>>.from(headers);
    map[header] = new List<String>.unmodifiable(
        map.putIfAbsent(header, () => <String>[]).toList()..add(value));
    map = new Map<String, List<String>>.unmodifiable(map);
    return fork(
      headers: map,
      method: method,
      url: url,
    );
  }

  PlatformSeltzerHttpRequest fork({
    @required Map<String, List<String>> headers,
    @required String method,
    @required String url,
  });

  @override
  Stream<SeltzerHttpResponse> send() {
    return new Stream<SeltzerHttpResponse>.fromFuture(
      sendPlatform().then((e) => new _DefaultSeltzerHttpResponse(e)),
    );
  }

  /// Returns a [Future] that completes with the raw result data of the request.
  ///
  /// Implement using platform-specific implementation.
  Future<String> sendPlatform();
}

/// An HTTP response object.
abstract class SeltzerHttpResponse<T> {
  /// Response payload.
  String get payload;
}

class _DefaultSeltzerHttpResponse<T> implements SeltzerHttpResponse<T> {
  @override
  final String payload;

  _DefaultSeltzerHttpResponse(this.payload);
}
