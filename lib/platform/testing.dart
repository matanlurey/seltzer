import 'dart:async';
import 'package:seltzer/src/context.dart';
import 'package:seltzer/src/interface.dart';

/// Initializes `package:seltzer/seltzer.dart` to use an in-memory fake.
///
/// In test environments it's useful to have canned responses.
void useSeltzerForTesting({
  CannedSeltzerHttp useHttp,
}) {
  if (useHttp != null) {
    setHttpPlatform(useHttp, true);
  }
}

/// A fake implementation of [SeltzerHttp].
///
/// Use [expect] to add expectations to return canned responses.
class CannedSeltzerHttp extends PlatformSeltzerHttp {
  static String _getKey(
    String method,
    String url,
    Map<String, String> headers,
  ) {
    return '$method|$url|$headers';
  }

  final Map<String, String> _expectations = <String, String>{};

  @override
  Future<SeltzerHttpResponse> execute(
    String method,
    String url, {
    Map<String, String> headers,
  }) {
    var response = _expectations.remove(_getKey(method, url, headers));
    if (response == null) {
      throw new StateError('No expectation found for $method $url');
    }
    return new Future<SeltzerHttpResponse>.value(
      new _FakeHttpResponse(response),
    );
  }

  /// Adds an expctation for [method] [url] [headers].
  void expect(
    String method,
    String url, {
    Map<String, String> headers: const {},
    String response: '',
  }) {
    _expectations[_getKey(method, url, headers)] = response;
  }
}

class _FakeHttpResponse implements SeltzerHttpResponse {
  @override
  final String payload;

  _FakeHttpResponse(this.payload);
}
