@TestOn('vm')
library seltzer.test.platform.browser_test;

import 'package:seltzer/platform/vm.dart';
import 'package:test/test.dart';

import '../../common/http.dart';

void main() {
  useSeltzerInVm();
  runHttpTests();
}
