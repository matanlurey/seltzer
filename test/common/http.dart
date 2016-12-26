import 'dart:convert';

import 'package:seltzer/seltzer.dart';
import 'package:test/test.dart';

const _echoUrl = 'http://localhost:9090';

/// Runs a common test suite that assumes a pre-configured Seltzer.
void runHttpTests() {
  test('should make a valid DELETE request', () async {
    var response = await delete('$_echoUrl/das/fridge/lacroix').send().first;
    expect(JSON.decode(await response.readAsString()), {
      'headers': {},
      'method': 'DELETE',
      'url': '/das/fridge/lacroix',
      'data': '',
    });
  });

  test('should make a valid GET request', () async {
    var response = await get('$_echoUrl/flags.json').send().first;
    expect(JSON.decode(await response.readAsString()), {
      'headers': {},
      'method': 'GET',
      'url': '/flags.json',
      'data': '',
    });
  });

  test('should make a valid PATCH request', () async {
    var response = await patch('$_echoUrl/pants/up').send().first;
    expect(JSON.decode(await response.readAsString()), {
      'headers': {},
      'method': 'PATCH',
      'url': '/pants/up',
      'data': '',
    });
  });

  test('should make a valid POST request', () async {
    var response = await post('$_echoUrl/users/clear').send().first;
    expect(JSON.decode(await response.readAsString()), {
      'headers': {},
      'method': 'POST',
      'url': '/users/clear',
      'data': '',
    });
  });

  test('should make a valid PUT request', () async {
    var response = await put('$_echoUrl/pants/on').send().first;
    expect(JSON.decode(await response.readAsString()), {
      'headers': {},
      'method': 'PUT',
      'url': '/pants/on',
      'data': '',
    });
  });

  test('should send an HTTP header', () async {
    var response =
        await (get(_echoUrl)..headers['Authorization'] = 'abc123').send().first;
    expect(JSON.decode(await response.readAsString()), {
      'headers': {
        'Authorization': 'abc123',
      },
      'method': 'GET',
      'url': '/',
      'data': '',
    });
  });
}
