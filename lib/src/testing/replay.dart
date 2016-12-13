import 'dart:async';

import 'package:reply/reply.dart';
import 'package:seltzer/seltzer.dart';
import 'package:seltzer/src/interface/http_request.dart';

/// An implementation of [SeltzerHttp] that plays back a recording.
class ReplaySeltzerHttp extends SeltzerHttp {
  final Recording<SeltzerHttpRequest, SeltzerHttpResponse> _recording;

  /// Create a new [ReplaySeltzerHttp] from a previous [recording].
  factory ReplaySeltzerHttp(
    Recording<SeltzerHttpRequest, SeltzerHttpResponse> recording,
  ) = ReplaySeltzerHttp._;

  /// Creates a new [ReplySeltzerHttp] from [pairs] of request/responses.
  factory ReplaySeltzerHttp.fromMap(
    Map<SeltzerHttpRequest, SeltzerHttpResponse> pairs,
  ) {
    final recorder = new Recorder<SeltzerHttpRequest, SeltzerHttpResponse>(
      requestEquality: const SeltzerHttpRequestEquality(),
    );
    pairs.forEach((request, response) {
      recorder.given(request).reply(response).once();
    });
    return new ReplaySeltzerHttp._(recorder.toRecording());
  }

  ReplaySeltzerHttp._(this._recording);

  @override
  Stream<SeltzerHttpResponse> handle(SeltzerHttpRequest request, [_]) {
    return new Stream<SeltzerHttpResponse>.fromIterable([
      _recording.reply(request),
    ]);
  }
}
