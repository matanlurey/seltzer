@TestOn('browser')
library seltzer.test.platform.web_socket.browser_test;

import 'package:seltzer/platform/browser.dart';
import 'package:test/test.dart';

import '../../common/ws.dart';

void main() {
  useSeltzerInTheBrowser();
  runSocketTests();
}
