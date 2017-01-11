import 'dart:async';
import 'dart:io';

import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/src/interface/http_server.dart';
import 'package:seltzer/src/interface/socket.dart';
import 'package:seltzer/src/socket_impl.dart';
import 'package:web_socket_channel/io.dart';

class DefaultSeltzerHttpServer implements SeltzerHttpServer {
  final StreamController<ServerSeltzerHttpRequest> _requestController =
      new StreamController<ServerSeltzerHttpRequest>.broadcast(sync: true);
  final StreamController<SeltzerWebSocket> _socketController =
      new StreamController<SeltzerWebSocket>.broadcast(sync: true);
  final HttpServer _delegate;

  StreamSubscription<HttpRequest> _delegateSubscription;

  DefaultSeltzerHttpServer.fromServer(this._delegate) {
    _delegateSubscription = _delegate.listen(_transformAndPipeRequest);
  }

  @override
  InternetAddress get address => _delegate.address;

  @override
  int get port => _delegate.port;

  @override
  Stream<ServerSeltzerHttpRequest> get requests => _requestController.stream;

  @override
  Stream<SeltzerWebSocket> get socketConnections => _socketController.stream;

  @override
  Future close({bool force: false}) async {
    return Future.wait([
      _delegateSubscription.cancel(),
      _requestController.close(),
      _socketController.close(),
    ]).then((_) => _delegate.close(force: force));
  }

  Future _transformAndPipeRequest(HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      var socket = await WebSocketTransformer.upgrade(request);
      var channel = new IOWebSocketChannel(socket);
      _socketController.add(new ChannelWebSocket(channel));
    } else {
      _requestController
          .add(new DefaultServerSeltzerHttpRequest.fromHttpRequest(request));
    }
  }
}

class DefaultServerSeltzerHttpRequest implements ServerSeltzerHttpRequest {
  @override
  final String method;
  @override
  final ServerSeltzerHttpResponse response;
  final HttpRequest _request;

  DefaultServerSeltzerHttpRequest.fromHttpRequest(HttpRequest request)
      : method = request.method,
        response = new DefaultServerSeltzerHttpResponse.fromHttpResponse(
            request.response),
        _request = request;

  /// The headers sent in this HTTP request.
  @override
  HttpHeaders get headers => _request.headers;
}

/// An object used to respond to a [ServerSeltzerHttpRequest].
class DefaultServerSeltzerHttpResponse implements ServerSeltzerHttpResponse {
  final HttpResponse _delegate;

  DefaultServerSeltzerHttpResponse.fromHttpResponse(this._delegate);

  @override
  HttpHeaders get headers => _delegate.headers;

  @override
  void addError(error, [StackTrace stacktrace]) {
    _delegate.addError(error, stacktrace);
  }

  @override
  void write(String data) {
    _delegate.write(data);
  }

  @override
  void writeln(String data) {
    _delegate.writeln(data);
  }

  @override
  Future close() => _delegate.close();
}
