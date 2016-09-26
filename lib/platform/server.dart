import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:seltzer/src/context.dart';
import 'package:seltzer/src/interface.dart';

export 'package:seltzer/seltzer.dart';

/// Initializes `package:seltzer/seltzer.dart` to use [ServerSeltzerHttp].
///
/// This is appropriate for clients running in the VM on the command line.
void useSeltzerInTheServer() => setPlatform(const ServerSeltzerHttp());

/// An implementation of [SeltzerHttp] that works within the browser.
///
/// The "server" means in the Dart VM on the command line.
class ServerSeltzerHttp extends PlatformSeltzerHttp {
  /// Use the default server implementation of [SeltzerHttp].
  @literal
  const factory ServerSeltzerHttp() = ServerSeltzerHttp._;

  const ServerSeltzerHttp._();

  @override
  Future<SeltzerHttpResponse> execute(
    String method,
    String url, {
    Map<String, String> headers,
  }) async {
    var request = await new HttpClient().openUrl(method, Uri.parse(url));
    headers.forEach(request.headers.add);
    var response = await request.close();
    var payload = await UTF8.decodeStream(response);
    return new _IOSeltzerHttpResponse(payload);
  }
}

class _IOSeltzerHttpResponse implements SeltzerHttpResponse {
  @override
  final String payload;

  _IOSeltzerHttpResponse(this.payload);
}
