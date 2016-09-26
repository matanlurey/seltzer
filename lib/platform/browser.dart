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
