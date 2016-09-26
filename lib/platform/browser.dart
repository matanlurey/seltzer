import 'dart:async';
import 'dart:html';

import 'package:meta/meta.dart';
import 'package:seltzer/src/context.dart';
import 'package:seltzer/src/interface.dart';

export 'package:seltzer/seltzer.dart';

/// Initializes `package:seltzer/seltzer.dart` to use [BrowserSeltzerHttp].
///
/// This is appropriate for clients running in Dartium, DDC, and dart2js.
void useSeltzerInTheBrowser() => setPlatform(const BrowserSeltzerHttp());

/// An implementation of [SeltzerHttp] that works within the browser.
///
/// The "browser" means support for Dartium, DDC, and dart2js.
abstract class BrowserSeltzerHttp implements SeltzerHttp {
  /// Use the default browser implementation of [SeltzerHttp].
  @literal
  const factory BrowserSeltzerHttp() = _HtmlSeltzerHttp;
}

class _HtmlSeltzerHttp extends PlatformSeltzerHttp
    implements BrowserSeltzerHttp {
  const _HtmlSeltzerHttp();

  @override
  SeltzerHttpRequest request(String method, String url) {
    return new _HtmlSeltzerHttpRequest(method, url);
  }
}

class _HtmlSeltzerHttpRequest extends PlatformSeltzerHttpRequest {
  _HtmlSeltzerHttpRequest(String method, String url,
      {Map<String, List<String>> headers: const {}})
      : super(
          headers: headers,
          method: method,
          url: url,
        );

  @override
  PlatformSeltzerHttpRequest fork({
    Map<String, List<String>> headers,
    String method,
    String url,
  }) {
    return new _HtmlSeltzerHttpRequest(method, url, headers: headers);
  }

  @override
  Future<String> sendPlatform() async {
    var requestHeaders = <String, String>{};
    headers.forEach((k, v) => requestHeaders[k] = v.first);
    var request = await HttpRequest.request(
      url,
      method: method,
      requestHeaders: requestHeaders,
    );
    return request.response;
  }
}
