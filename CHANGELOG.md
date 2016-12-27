# Changelog

## 0.4.0

- **BREAKING** `readAs<Bytes|String>` to return a `Stream` and `Future` instead
  - This is due to the potentially streaming nature of network and file i/o
  - For example, HTTP servers commonly send chunked responses
- Added `readAsBytesAll` to auto-concatenate buffers together
- Fix various strong-mode warnings

## 0.3.0

- Use `WebSocketChannel` as the backing implementation for sockets
- Replace `sendX` and `close` methods to return `void` instead of `Future`

## 0.2.4-alpha

- Added `ReplaySeltzerHttp` and `SeltzerHttpRecorder` for testing

## 0.2.3-alpha

- Added `SeltzerSocketClosedEvent` with information why close occurred
- Rename the `Server` implementations to `Vm` since they work on Flutter
- Simplified how to extend/transform HTTP clients
- Removed `CannedSeltzerHttp`; to be re-added/re-worked by 0.3

## 0.2.2-alpha

- Consolidated interfaces of `SeltzerMessage` and `SeltzerHttpResponse`
  - Both support synchronous `readAsString` and `readAsBytes`
- Fixed various strong mode warnings related to type inference
- Moved "echo" servers from bin/ to tool/ (implementation detail)

## 0.2.0-alpha

- Added `CannedHttpResponse` and the `platform/testing.dart` library
- Added response headers to `SeltzerHttpResponse`
