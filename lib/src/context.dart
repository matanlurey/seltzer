import 'package:seltzer/src/interface.dart';

// The currently configured implementation of Seltzer.
//
// Users are expected to import 'platform/*.dart', and use a configuration
// method to initialize this variable before using the top-level methods found
// in this class.
//
// Once we have configurable import support then we can deprecate needing this.
SeltzerHttp _platform;

// The current configured _WebSocketProvider.
//
// As with the getter `_platform`, users are expected to use a configuration
// method to initialize this provider.
SeltzerWebSocketProvider _platformSocket;

const _platformAlreadySetError = 'Platform already initialized. In most` '
    'applications, you need only to configure the "useSeltzerInTheX" platform '
    'method *once*; doing so more than once may introduce subtle/unsupported '
    'bugs.';

/// Internal method: Initializes the top-level methods to use [platform].
void setHttpPlatform(SeltzerHttp platform, [bool allowOverride = false]) {
  assert(() {
    if (!allowOverride && _platform != null) {
      throw new StateError(_platformAlreadySetError);
    }
    return true;
  });
  _platform = platform;
}

/// Internal method: Sets the callback for creating [SeltzerWebSocket]s.
void setSocketPlatform(SeltzerWebSocketProvider provider) {
  assert(() {
    if (_platformSocket != null) {
      throw new StateError(_platformAlreadySetError);
    }
    return true;
  });
  _platformSocket = provider;
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

/// Connects to a [web socket](https://tools.ietf.org/html/rfc6455) at [url].
///
/// Uses the currently configured platform configuration.
SeltzerWebSocket connect(String url) => _platformSocket(url);

/// Creates a `DELETE` HTTP request to [url].
///
/// See [SeltzerHttp.delete].
SeltzerHttpRequest delete(String url) => _seltzer.delete(url);

/// Creates a `GET` HTTP request to [url].
///
/// See [SeltzerHttp.get].
SeltzerHttpRequest get(String url) => _seltzer.get(url);

/// Creates a `PATCH` HTTP request to [url].
///
/// See [SeltzerHttp.patch].
SeltzerHttpRequest patch(String url) => _seltzer.patch(url);

/// Creates a `POST` HTTP request to [url].
///
/// See [SeltzerHttp.post].
SeltzerHttpRequest post(String url) => _seltzer.post(url);

/// Creates a `PUT` HTTP request to [url].
///
/// See [SeltzerHttp.put].
SeltzerHttpRequest put(String url) => _seltzer.put(url);
