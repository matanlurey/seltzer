@TestOn('vm')
library seltzer.test.platform.browser_test;

import 'package:seltzer/platform/server.dart';
import 'package:test/test.dart';

import '../../common/http.dart';

void main() {
  useSeltzerInTheServer();
  runHttpTests();
}
