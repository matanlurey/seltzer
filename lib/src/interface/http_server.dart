import 'dart:async';
import 'dart:io';

import 'package:seltzer/src/http_server_impl.dart';
import 'package:seltzer/src/interface/http_request.dart';
import 'package:seltzer/src/interface/socket.dart';

/// An HTTP server that emits HTTP requests and socket connections.
abstract class SeltzerHttpServer {
  /// Starts listening for HTTP requests on the specified [address] and [port].
  ///
  /// [address] can be either a [String] or an [InternetAddress].  If it is a
  /// [String] then the first value in [InternetAddress.lookup] will be used.
  ///
  /// If [port] is 0, an ephemeral port will be chosen by the system. The actual
  /// port used can be retrieved using the [port] getter.
  ///
  /// [backlog] can be used to specify the listen backlog for the underlying OS
  /// listen setup. It has the default value of 0 (default will be chosen by the
  /// system).
  ///
  /// [shared] specifies whether additional servers can bind to the same
  /// combination of [address], [port] and [v6Only].  If shared is true,
  /// Incoming connections are distributed among all bound servers.
  static Future<SeltzerHttpServer> bind(
    address,
    int port, {
    int backlog: 0,
    bool v6Only: false,
    bool shared: false,
  }) async =>
      new DefaultSeltzerHttpServer.fromServer(await HttpServer.bind(
        address,
        port,
        backlog: backlog,
        v6Only: v6Only,
        shared: shared,
      ));

  /// The address this server is listening on.
  InternetAddress get address;

  /// The port this server is listening on.
  int get port;

  /// The stream of [SeltzerHttpRequest]s received by this server.
  Stream<ServerSeltzerHttpRequest> get requests;

  /// The stream of [SeltzerWebSocket] connections received by this server.
  Stream<SeltzerWebSocket> get socketConnections;

  /// Permanently stops this server from listening for new connections.
  ///
  /// This closes the stream of requests and socket connections with a done
  /// event. The returned future completes when the server is stopped and the
  /// corresponding port is no longer in use.
  Future close({bool force: false});
}

/// An incoming HTTP request which allows sending data back to the client.
abstract class ServerSeltzerHttpRequest {
  /// The HTTP method used by this request.
  String get method;

  /// The response object for sending data back to the client.
  ServerSeltzerHttpResponse get response;

  /// The headers sent in this HTTP request.
  HttpHeaders get headers;
}

/// An object used to respond to a [ServerSeltzerHttpRequest].
abstract class ServerSeltzerHttpResponse {
  /// The headers to send in this HTTP response.
  HttpHeaders get headers;

  /// Passes the error to the client as an error event.
  void addError(error, [StackTrace stacktrace]);

  /// Sends [data] to he client.
  void write(String data);

  /// Sends [data] with a newline appended to the client.
  void writeln(String data);

  /// Permanently closes the request.
  ///
  /// No more data may be written by this request.  The client will hang until
  /// this is called.
  Future close();
}
