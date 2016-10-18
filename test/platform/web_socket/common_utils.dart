import 'dart:typed_data';

import 'package:seltzer/seltzer.dart';
import 'package:test/test.dart';

const _echoUrl = 'ws://localhost:9095';

/// Runs a common test suite that assumes a pre-configured Seltzer.
void runPlatformTests() {
  group('$SeltzerWebSocket', () {
    SeltzerWebSocket webSocket;

    setUp(() async {
      webSocket = createWebSocket(_echoUrl);
    });

    tearDown(() => webSocket?.close());

    test('onOpen should emit single event when the stream opens.', () async {
      expect(webSocket.onOpen.single, completion(null));
    });

    group('onClose', () {
      tearDown(() {
        // prevent tearDown when socket already closed.
        webSocket = null;
      });

      test('should emit a single event when the stream closes.', () async {
        await webSocket.onOpen.single;
        webSocket.close();
        expect(webSocket.onClose.single, completion(null));
      });

      test('should throw a StateError if called after the socket closes',
          () async {
        await webSocket.onOpen.single;
        webSocket.close();
        await webSocket.onClose.single;
        expect(webSocket.close(), throwsStateError);
      });
    });

    test('should throw a StateError if data is sent after the socket closes',
        () async {
      await webSocket.onOpen.single;
      webSocket.close();
      await webSocket.onClose.single;
      expect(webSocket.sendString('hello-world'), throwsStateError);
      expect(
          webSocket.sendBytes(new Uint8List(07734).buffer), throwsStateError);
      // prevent tearDown when socket already closed.
      webSocket = null;
    });

    test('sendString should send string data.', () async {
      var payload = 'string data';
      await webSocket.onOpen.single;
      webSocket.onMessage.listen(expectAsync((message) {
        expect(message.readAsString(), completion(payload));
      }, count: 1));
      webSocket.sendString(payload);
    });

    test('sendBytes should send byte data.', () async {
      var payload = new Int8List.fromList([1, 2]);
      await webSocket.onOpen.single;
      webSocket.onMessage.listen(expectAsync((message) {
        message.readAsArrayBuffer().then((ByteBuffer buffer) {
          expect(buffer.asInt8List(), payload);
        });
      }, count: 1));
      webSocket.sendBytes(payload.buffer);
    });
  });
}
