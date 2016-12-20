import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:seltzer/src/context.dart';
import 'package:seltzer/src/interface.dart';
import 'package:seltzer/src/socket_impl.dart';
import 'package:web_socket_channel/html.dart';

export 'package:seltzer/seltzer.dart';

/// Initializes `package:seltzer/seltzer.dart` to use [BrowserSeltzerHttp].
///
/// This is appropriate for clients running in Dartium, DDC, and dart2js.
void useSeltzerInTheBrowser() {
  setHttpPlatform(const BrowserSeltzerHttp());
  setSocketPlatform((String url) =>
      new ChannelWebSocket(new HtmlWebSocketChannel.connect(url)));
}

/// An implementation of [SeltzerHttp] that works within the browser.
///
/// The "browser" means support for Dartium, DDC, and dart2js.
class BrowserSeltzerHttp extends SeltzerHttp {
  /// Use the default browser implementation of [SeltzerHttp].
  @literal
  const factory BrowserSeltzerHttp() = BrowserSeltzerHttp._;

  const BrowserSeltzerHttp._();

  @override
  Stream<SeltzerHttpResponse> handle(
    SeltzerHttpRequest request, [
    Object payload,
  ]) {
    return HttpRequest
        .request(
          request.url,
          method: request.method,
          requestHeaders: request.headers,
          sendData: payload,
        )
        .asStream()
        .map((r) => new SeltzerHttpResponse(
              r.response,
              headers: r.responseHeaders,
            ));
  }
}
