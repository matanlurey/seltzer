import 'dart:convert';

import 'package:seltzer/seltzer.dart';
import 'package:test/test.dart';

const _echoUrl = 'http://localhost:9090';

/// Runs a common test suite that assumes a pre-configured Seltzer.
void runPlatformTests() {
  test('should make a valid GET request', () async {
    var response = await get('$_echoUrl/flags.json').send().first;
    expect(JSON.decode(response.payload), {
      'method': 'GET',
      'url': '/flags.json',
      'data': '',
    });
  });

  test('should make a valid POST request', () async {
    var response = await post('$_echoUrl/users/clear').send().first;
    expect(JSON.decode(response.payload), {
      'method': 'POST',
      'url': '/users/clear',
      'data': '',
    });
  });

  test('should send an HTTP header', () async {
    var response =
        await get(_echoUrl).set('Authorization', 'abc123').send().first;
    expect(JSON.decode(response.payload), {
      'headers': {
        'Authorization': 'abc123',
      },
      'method': 'GET',
      'url': '/',
      'data': '',
    });
  });
}
