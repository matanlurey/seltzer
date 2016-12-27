import 'package:seltzer/src/context.dart';
import 'package:seltzer/src/interface/http.dart';

export 'package:seltzer/src/testing/record.dart' show SeltzerHttpRecorder;
export 'package:seltzer/src/testing/replay.dart' show ReplaySeltzerHttp;

/// Initializes `package:seltzer/seltzer.dart` to use [implementation].
///
/// This is appropriate for test implementations that want to use an existing
/// implementation, such as a replay-based HTTP mock or server.
void useSeltzerForTesting(SeltzerHttp implementation) {
  setHttpPlatform(implementation);
}
