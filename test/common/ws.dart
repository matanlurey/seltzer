import 'dart:async';
import 'dart:typed_data';

import 'package:seltzer/seltzer.dart';
import 'package:test/test.dart';

const _echoUrl = 'ws://localhost:9095';

/// Runs a common test suite that assumes a pre-configured Seltzer.
void runSocketTests() {
  group('$SeltzerWebSocket', () {
    SeltzerWebSocket webSocket;

    setUp(() async {
      webSocket = await connect(_echoUrl);
    });

    group('onClose', () {
      tearDown(() {
        // prevent tearDown when socket already closed.
        webSocket = null;
      });

      test('should emit a single event when the stream closes.', () async {
        webSocket.close();
        expect(webSocket.onClose, completion(isNotNull));
      });

      test('should throw a StateError if called after the socket closes',
          () async {
        await webSocket.close();
        await webSocket.onClose;
        expect(webSocket.close(), throwsStateError);
      });
    });

    test('should throw a StateError if data is sent after the socket closes',
        () async {
      await webSocket.close();
      await webSocket.onClose;
      expect(webSocket.sendString('hello-world'), throwsStateError);
      expect(
        webSocket.sendBytes(new Uint8List(07734).buffer),
        throwsStateError,
      );
      // prevent tearDown when socket already closed.
      webSocket = null;
    });

    test('sendString should send string data.', () async {
      var payload = 'string data';
      var completer = new Completer();
      webSocket.onMessage.listen(((message) {
        expect(message.readAsString(), payload);
        completer.complete();
      }));
      webSocket.sendString(payload);
      await completer.future;
    });

    test('sendBytes should send byte data.', () async {
      var payload = new Int8List.fromList([1, 2]);
      var completer = new Completer();
      webSocket.onMessage.listen((message) {
        expect(message.readAsBytes(), payload);
        completer.complete();
      });
      webSocket.sendBytes(payload.buffer);
      await completer.future;
    });
  });
}
