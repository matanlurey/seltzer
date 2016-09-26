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
  SeltzerHttpRequest get(String url) => request('GET', url);

  @override
  @mustCallSuper
  SeltzerHttpRequest post(String url) => request('POST', url);

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

/// An HTTP response object.
abstract class SeltzerHttpResponse {
  /// Response payload.
  String get payload;
}
