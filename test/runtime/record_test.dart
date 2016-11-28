@TestOn('vm')
import 'dart:convert';

import 'package:seltzer/platform/testing.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:test/test.dart';

const _echoUrl = 'http://localhost:9090';

main() {
  SeltzerHttp http;
  SeltzerHttpRecorder recorder;

  setUp(() {
    recorder = new SeltzerHttpRecorder(const VmSeltzerHttp());
    http = recorder.asHttpClient();
  });

  runPingTest() async {
    final response = await http.post('$_echoUrl/ping').send().last;
    expect(JSON.decode(response.readAsString()), {
      'data': '',
      'headers': {},
      'method': 'POST',
      'url': '/ping',
    });
  }

  test('should record a request/response', () async {
    await runPingTest();
    final recording = recorder.toRecording();

    expect(
      recording.hasRecord(new SeltzerHttpRequest(
        'POST',
        '$_echoUrl/ping',
      )),
      isTrue,
    );

    // Now lets try replaying without a real HTTP connection.
    http = new ReplaySeltzerHttp(recording);
    await runPingTest();
  });
}
