import 'dart:io';

/// A simple WebSocket server that echoes back data.
main(List<String> args) async {
  const port = 9095;
  final server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port);
  server.listen((request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen(socket.add, onError: socket.addError);
    }
  });
}
