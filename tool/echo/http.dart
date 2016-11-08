import 'dart:convert';
import 'dart:io';

import 'package:seltzer/src/internal/echo.dart';

/// A simple HTTP server that echoes back a formatted JSON blob.
main(List<String> args) async {
  const port = 9090;
  final server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port);
  print('Listening to ${server.address.host}:${server.port}');

  await for (final request in server) {
    const {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Authorization',
      'Access-Control-Allow-Methods': 'DELETE, OPTIONS, PATCH, PUT, POST',
      'Content-Type': 'application/json',
    }.forEach(request.response.headers.set);
    final headers = <String, dynamic>{};
    final authorization = request.headers['Authorization'];
    if (authorization != null) {
      headers['Authorization'] = authorization.first;
    }
    final payload = new EchoHttpPayload(
      data: (await UTF8.decodeStream(request)),
      headers: headers,
      method: request.method,
      url: request.uri.toString(),
    );
    request.response.write(JSON.encode(payload));
    await request.response.close();
  }
}
