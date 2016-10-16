@TestOn('vm')
library seltzer.test.platform.web_socket.server_test;

import 'package:seltzer/platform/server.dart';
import 'package:test/test.dart';

import 'common_utils.dart';

void main() {
  useSeltzerInTheServer();
  runPlatformTests();
}
