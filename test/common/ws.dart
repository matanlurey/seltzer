import 'dart:async';
import 'dart:typed_data';

import 'package:seltzer/seltzer.dart';
import 'package:test/test.dart';

const _echoUrl = 'ws://localhost:9095';

/// Runs a common test suite that assumes a pre-configured Seltzer.
void runSocketTests() {
  group('$SeltzerWebSocket', () {
    SeltzerWebSocket webSocket;

    setUp(() {
      webSocket = connect(_echoUrl);
    });

    test('onClose should emit an event when the stream closes.', () async {
      webSocket.close();
      expect(await webSocket.onClose, isNotNull);
    });

    test('sendString should send string data.', () async {
      var payload = 'string data';
      var completer = new Completer();
      webSocket.onMessage.listen(((message) async {
        expect(await message.readAsString(), payload);
        completer.complete();
      }));
      webSocket.sendString(payload);
      await completer.future;
    });

    test('sendBytes should send byte data.', () async {
      var payload = new Int8List.fromList([1, 2]);
      var completer = new Completer();
      webSocket.onMessage.listen((message) async {
        expect(await message.readAsBytes().first, payload);
        completer.complete();
      });
      webSocket.sendBytes(payload.buffer);
      await completer.future;
    });

    group('close', () {
      test('should prevent sending further messages', () async {
        webSocket.close();
        await webSocket.onClose;
        expect(() => webSocket.sendString('A'), throwsStateError);
        expect(() => webSocket.sendBytes(new Int8List(1).buffer),
            throwsStateError);
      });

      test('should prevent further calls to close', () async {
        webSocket.close();
        await webSocket.onClose;
        expect(() => webSocket.close(), throwsStateError);
      });
    });
  });
}
