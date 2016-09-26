import 'dart:async';

import 'package:meta/meta.dart';

/// Elegant and rich cross-platform HTTP service.
///
/// See `platform/browser.dart` and `platform/server.dart` for implementations.
abstract class SeltzerHttp {
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

/// An HTTP request object.
///
/// Every [SeltzerHttpRequest] object implements the [Stream] interface via
/// [SeltzerHttpRequest.send].
///
/// In most simple use cases [Stream.first] will connect and return a value:
///     get('some/url.json').send().first.then((value) => print('Got: $value'));
///
/// Some implementations of [SeltzerHttp] may choose to allow multiple responses
/// and/or respond with a local cache first, and then make a response against
/// the server. In that case, [Stream.listen] may be preferred:
///     get('some/url.json').send().listen((value) {
///       print('Got: $value');
///     });
abstract class SeltzerHttpRequest {
  /// HTTP method to use.
  String get method;

  /// URL to send the request to.
  String get url;

  /// Makes the HTTP request, and returns a [Stream] of results.
  Stream<SeltzerHttpResponse> /*=Stream<SeltzerHttpResponse<E>>*/ send/*<E>*/();
}

/// A partial implementation of [SeltzerHttpRequest] without platform specifics.
abstract class PlatformSeltzerHttpRequest implements SeltzerHttpRequest {
  @override
  final String method;

  @override
  final String url;

  /// Initialize a new [PlatformSeltzerHttpRequest].
  PlatformSeltzerHttpRequest({
    @required this.method,
    @required this.url,
  });

  @override
  Stream<
      SeltzerHttpResponse> /*=Stream<SeltzerHttpResponse<E>>*/ send/*<E>*/() {
    return new Stream<SeltzerHttpResponse/*<E>*/ >.fromFuture(
      sendPlatform().then((e) => new _DefaultSeltzerHttpResponse/*<E>*/(e)),
    );
  }

  /// Implement using platform-specific implementation.
  Future/*<String>*/ sendPlatform();
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
