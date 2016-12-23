import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:seltzer/src/context.dart';
import 'package:seltzer/src/interface.dart';
import 'package:seltzer/src/socket_impl.dart';
import 'package:web_socket_channel/io.dart';

export 'package:seltzer/seltzer.dart';

/// Initializes `package:seltzer/seltzer.dart` to use [VmSeltzerHttp].
///
/// This is appropriate for clients running in the VM on the command line.
void useSeltzerInVm() {
  setHttpPlatform(const VmSeltzerHttp());
  setSocketPlatform(
    (String url) => new ChannelWebSocket(new IOWebSocketChannel.connect(url)),
  );
}

/// An implementation of [SeltzerHttp] implemented via the Dart VM.
///
/// Worsk in the Dart VM on the command line or AoT compiled in Flutter.
class VmSeltzerHttp extends SeltzerHttp {
  /// Use the default VM implementation of [SeltzerHttp].
  @literal
  const factory VmSeltzerHttp() = VmSeltzerHttp._;

  const VmSeltzerHttp._();

  @override
  Stream<SeltzerHttpResponse> handle(SeltzerHttpRequest request,
      [Object data]) {
    return new HttpClient()
        .openUrl(request.method, Uri.parse(request.url))
        .then((r) async {
      request.headers.forEach(r.headers.add);
      final response = await r.close();
      final payload = await response.first;
      final headers = <String, String>{};
      response.headers.forEach((name, value) {
        headers[name] = value.join(' ');
      });
      if (payload is String) {
        return new SeltzerHttpResponse.fromString(payload, headers: headers);
      } else {
        return new SeltzerHttpResponse.fromBytes(payload, headers: headers);
      }
    }).asStream();
  }
}
