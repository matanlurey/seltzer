/// An elegant and rich cross-platform HTTP library for Dart.
library seltzer;

// Re-export convenience functions that are platform independent.
export 'package:seltzer/src/context.dart'
    show delete, get, patch, post, put, connect;

// Re-export common interfaces that might be referred to.
export 'package:seltzer/src/interface.dart'
    show
        SeltzerHttp,
        SeltzerHttpRequest,
        SeltzerHttpResponse,
        SeltzerHttpTransformer,
        SeltzerWebSocket,
        SeltzerWebSocketTransformer;
