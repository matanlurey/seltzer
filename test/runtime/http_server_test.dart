@TestOn('vm')
import 'dart:io';
import 'package:seltzer/platform/vm.dart';
import 'package:test/test.dart';

void main() {
  useSeltzerInVm();

  String httpUrl(InternetAddress address, int port) =>
      'http://${address.host}:$port';
  String wsUrl(InternetAddress address, int port) =>
      'ws://${address.host}:$port';

  group('$SeltzerHttpServer', () {
    test('bind should return a SeltzerHttpServer listening for connections',
        () async {
      var message = 'Hello World!';
      var server = await SeltzerHttpServer.bind('localhost', 0);

      server.listen((request) {
        request.response.write(message);
        request.response.close();
      });

      var response =
          await get(httpUrl(server.address, server.port)).send().first;
      expect(await response.readAsString(), message);
      await server.close(force: true);
    });

    group('instance', () {
      const int testPort = 8080;
      final InternetAddress testHost = InternetAddress.ANY_IP_V4;
      SeltzerHttpServer server;

      setUp(() async {
        server = await SeltzerHttpServer.bind(testHost, testPort);
      });

      tearDown(() => server.close(force: true));

      test('address should return the address the server is listening on',
          () async {
        expect(server.address, testHost);
      });

      test('port should return the port the server is listening on', () async {
        expect(server.port, testPort);
      });

      test('requests should be a stream of HTTP requests', () async {
        server.listen(expectAsync1((request) {
          expect(request.method, 'POST');
        }, count: 1));
        post(httpUrl(server.address, server.port)).send();
      });

      test('socketConnections should be a stream of socket connections',
          () async {
        server.socketConnections.listen(expectAsync1((_) {}, count: 1));
        connect(wsUrl(server.address, server.port));
      });

      test('close should permanently shutdown the server', () async {
        expect(server.address, testHost);
        expect(server.port, testPort);
        await server.close();
        expect(() => server.address, throws);
        expect(() => server.port, throws);
      });
    });
  });
}
