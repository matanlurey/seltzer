import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

/// A simple WebSocket server that echoes any request data.
///
/// You may specify a port directly:
///     dart bin/echo.dart --port 9091
Future main(List<String> args) async {
  final port = int.parse(_argParser.parse(args)['port'], onError: (_) => 0);
  if (port == 0) {
    print('Could not parse port from $args.');
    exit(1);
  }

  final server = await HttpServer.bind('127.0.0.1', port);
  print('Listening on ${server.address.host}:${server.port}');
  server.listen((HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      var webSocket = await WebSocketTransformer.upgrade(request);
      webSocket.listen(webSocket.add, onError: webSocket.addError);
    }
  });
}

final ArgParser _argParser = new ArgParser()
  ..addOption(
    'port',
    defaultsTo: '9091',
  );
