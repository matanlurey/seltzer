import 'dart:async';

import 'http_request.dart';
import 'http_response.dart';

/// Actually handles sending a [SeltzerHttpRequest].
///
/// May be implemented to support a simplified model of handling requests.
abstract class SeltzerHttpHandler {
  const SeltzerHttpHandler();

  /// Executes an HTTP [request].
  ///
  /// If [payload] is specified:
  /// - A [String] and [List<int>] is sent as-is.
  /// - Anything else is sent by encoding as JSON.
  Stream<SeltzerHttpResponse> handle(
    SeltzerHttpRequest request, [
    Object payload,
  ]);

  /// Returns the handler as [SeltzerHttp] instance.
  SeltzerHttp asHttpClient() => new _AsHttpClient(this);
}

/// Elegant and rich cross-platform HTTP service.
///
/// See `platform/browser.dart` and `platform/vm.dart` for implementations.
abstract class SeltzerHttp extends SeltzerHttpHandler {
  const SeltzerHttp();

  /// Create a request to DELETE from [url].
  SeltzerHttpRequest delete(String url) => _request('DELETE', url);

  /// Create a request to GET to [url].
  SeltzerHttpRequest get(String url) => _request('GET', url);

  /// Create a request to PATCH to [url].
  SeltzerHttpRequest patch(String url) => _request('PATCH', url);

  /// Create a request to POST to [url].
  SeltzerHttpRequest post(String url) => _request('POST', url);

  /// Create a request to PUT to [url].
  SeltzerHttpRequest put(String url) => _request('PUT', url);

  SeltzerHttpRequest _request(String method, String url) {
    return new SeltzerHttpRequest.fromHandler(
      this,
      method: method,
      url: url,
    );
  }
}

class _AsHttpClient extends SeltzerHttp {
  final SeltzerHttpHandler _handler;

  const _AsHttpClient(this._handler);

  @override
  SeltzerHttp asHttpClient() => this;

  @override
  Stream<SeltzerHttpResponse> handle(
    SeltzerHttpRequest request, [
    Object payload,
  ]) {
    return _handler.handle(request, payload);
  }
}
