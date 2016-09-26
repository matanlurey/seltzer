import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

/// A simple HTTP server that echoes back a JSON blob like:
///     {
///       "method": "...",
///       "url": "...",
///       "data": "...",
///     }
///
/// You may specify a port directly:
///     dart bin/echo.dart --port 9090
Future main(List<String> args) async {
  final port = int.parse(_argParser.parse(args)['port'], onError: (_) => 0);
  if (port == 0) {
    print('Could not parse port from $args.');
    exit(1);
  }
  final server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port);
  print('Listening on ${server.address.host}:${server.port}');
  await for (final request in server) {
    request.response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..contentType = ContentType.JSON;
    final headers = <String, List<String>>{};
    request.headers['X-Echo-Header']?.forEach((v) {
      headers[v] = request.headers[v];
    });
    final payload = <String, dynamic>{
      'method': request.method,
      'url': request.uri.toString(),
      'data': await UTF8.decodeStream(request)
    };
    if (headers.isNotEmpty) {
      payload['headers'] = headers;
    }
    request.response.write(JSON.encode(payload));
    await request.response.close();
  }
}

final ArgParser _argParser = new ArgParser()
  ..addOption(
    'port',
    defaultsTo: '9090',
  );
