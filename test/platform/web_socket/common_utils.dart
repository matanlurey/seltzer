import 'package:seltzer/seltzer.dart';
import 'package:test/test.dart';

const _echoUrl = 'ws://localhost:9095';

/// Runs a common test suite that assumes a pre-configured Seltzer.
void runPlatformTests() {
  group('$SeltzerWebSocket', () {
    SeltzerWebSocket webSocket;

    setUp(() async {
      webSocket = createWebSocket();
      await webSocket.open(_echoUrl);
    });

    tearDown(() async {
      await webSocket.close();
    });

    test('should send and receive data', () async {
      var payload = 'string data';
      webSocket.onData.listen(expectAsync((message) {
        expect(message, payload);
      }, count: 1));
      webSocket.sendString(payload);
    });
  });
}
