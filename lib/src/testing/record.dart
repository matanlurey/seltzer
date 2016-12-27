import 'dart:async';

import 'package:reply/reply.dart';
import 'package:seltzer/seltzer.dart';
import 'package:seltzer/src/interface/http_request.dart';

/// An interceptor/delegate [SeltzerHttp] that records request/response pairs.
class SeltzerHttpRecorder extends SeltzerHttpHandler {
  final SeltzerHttpHandler _delegate;
  final Recorder<SeltzerHttpRequest, SeltzerHttpResponse> _recorder;

  factory SeltzerHttpRecorder(SeltzerHttpHandler delegate) {
    return new SeltzerHttpRecorder._(
      delegate,
      new Recorder<SeltzerHttpRequest, SeltzerHttpResponse>(
        requestEquality: const SeltzerHttpRequestEquality(),
      ),
    );
  }

  SeltzerHttpRecorder._(this._delegate, this._recorder);

  @override
  Stream<SeltzerHttpResponse> handle(
    SeltzerHttpRequest request, [
    Object payload,
  ]) {
    SeltzerHttpResponse last;
    final transformer = new StreamTransformer<SeltzerHttpResponse,
        SeltzerHttpResponse>.fromHandlers(
      handleData: (event, sink) {
        last = event;
        sink.add(event);
      },
      handleDone: (sink) {
        _recorder.given(request).reply(last).once();
        sink.close();
      },
    );
    return _delegate.handle(request, payload).transform(transformer);
  }

  /// Returns all recorded request/response pairs.
  Recording<SeltzerHttpRequest, SeltzerHttpResponse> toRecording() {
    return _recorder.toRecording();
  }
}
