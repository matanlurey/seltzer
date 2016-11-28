import 'dart:convert';

import 'package:seltzer/seltzer.dart';
import 'package:seltzer/platform/testing.dart';

import '../common/http.dart';

main() {
  useSeltzerForTesting(
    new ReplaySeltzerHttp.fromMap({
      // "should make a valid DELETE request"
      new SeltzerHttpRequest(
        'DELETE',
        'http://localhost:9090/das/fridge/lacroix',
      ): new SeltzerHttpResponse.fromString(JSON.encode({
        'headers': {},
        'method': 'DELETE',
        'url': '/das/fridge/lacroix',
        'data': '',
      })),

      // "should make a valid GET request"
      new SeltzerHttpRequest(
        'GET',
        'http://localhost:9090/flags.json',
      ): new SeltzerHttpResponse.fromString(JSON.encode({
        'headers': {},
        'method': 'GET',
        'url': '/flags.json',
        'data': '',
      })),

      // "should make a valid PATCH request"
      new SeltzerHttpRequest(
        'PATCH',
        'http://localhost:9090/pants/up',
      ): new SeltzerHttpResponse.fromString(JSON.encode({
        'headers': {},
        'method': 'PATCH',
        'url': '/pants/up',
        'data': '',
      })),

      // "should make a valid POST request"
      new SeltzerHttpRequest(
        'POST',
        'http://localhost:9090/users/clear',
      ): new SeltzerHttpResponse.fromString(JSON.encode({
        'headers': {},
        'method': 'POST',
        'url': '/users/clear',
        'data': '',
      })),

      // "should make a valid PUT request"
      new SeltzerHttpRequest(
        'PUT',
        'http://localhost:9090/pants/on',
      ): new SeltzerHttpResponse.fromString(JSON.encode({
        'headers': {},
        'method': 'PUT',
        'url': '/pants/on',
        'data': '',
      })),

      // "should send an HTTP header"
      new SeltzerHttpRequest(
        'GET',
        'http://localhost:9090',
        headers: {
          'Authorization': 'abc123',
        },
      ): new SeltzerHttpResponse.fromString(JSON.encode({
        'headers': {
          'Authorization': 'abc123',
        },
        'method': 'GET',
        'url': '/',
        'data': '',
      }))
    }),
  );

  runHttpTests();
}
