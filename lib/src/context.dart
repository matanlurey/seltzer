import 'package:seltzer/src/interface.dart';

// The currently configured implementation of Seltzer.
//
// Users are expected to import 'platform/*.dart', and use a configuration
// method to initialize this variable before using the top-level methods found
// in this class.
//
// Once we have configurable import support then we can deprecate needing this.
SeltzerHttp _platform;

/// Internal method: Initializes the top-level methods to use [platform].
void setPlatform(SeltzerHttp platform) {
  assert(() {
    if (_platform != null) {
      throw new StateError(
          'Platform already initialized. In most applications, you need only '
          'to configure the "useSeltzerInTheX" platform method *once*; doing '
          'so more than once may introduce subtle/unsupported bugs.');
    }
    return true;
  });
  _platform = platform;
}

/// Internal method: Returns the top-level instance.
SeltzerHttp getPlatform() => _seltzer;

// Asserts that _platform is non-null before returning.
SeltzerHttp get _seltzer {
  assert(() {
    if (_platform == null) {
      throw new StateError(
          'Seltzer is not initialized. You must import a platform-specific '
          'configuration of Seltzer, and use a cooresponding "useSeltzerInTheX" '
          'method in order to use the top-level methods like "get" or "post". '
          '\n\n'
          'See README.md#getting-started for more details');
    }
    return true;
  });
  return _platform;
}

/// See [SeltzerHttp.delete].
SeltzerHttpRequest delete(String url) => _seltzer.delete(url);

/// See [SeltzerHttp.get].
SeltzerHttpRequest get(String url) => _seltzer.get(url);

/// See [SeltzerHttp.patch].
SeltzerHttpRequest patch(String url) => _seltzer.patch(url);

/// See [SeltzerHttp.post].
SeltzerHttpRequest post(String url) => _seltzer.post(url);

/// See [SeltzerHttp.put].
SeltzerHttpRequest put(String url) => _seltzer.put(url);
