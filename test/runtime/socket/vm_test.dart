@TestOn('vm')
library seltzer.test.platform.web_socket.vm_test;

import 'package:seltzer/platform/vm.dart';
import 'package:test/test.dart';

import '../../common/ws.dart';

void main() {
  useSeltzerInVm();
  runSocketTests();
}
