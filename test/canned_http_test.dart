import 'package:seltzer/platform/testing.dart';
import 'package:test/test.dart';

void main() {
  test('should fail if an expectation is missing', () {
    expect(() => new CannedSeltzerHttp().get('/404').send(), throwsStateError);
  });

  test('should return the canned response', () async {
    var http = new CannedSeltzerHttp();
    http.expect('GET', '/fake/url', response: 'Hello World');
    expect(
      (await http.get('/fake/url').send().first).payload,
      'Hello World',
    );
  });
}
