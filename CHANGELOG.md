# Changelog

## 0.2.3-alpha

- Added `SeltzerSocketClosedEvent` with information why close occurred
- Rename the `Server` implementations to `Vm` since they work on Flutter

## 0.2.2-alpha

- Consolidated interfaces of `SeltzerMessage` and `SeltzerHttpResponse`
  - Both support synchronous `readAsString` and `readAsBytes`
- Fixed various strong mode warnings related to type inference
- Moved "echo" servers from bin/ to tool/ (implementation detail)

## 0.2.0-alpha

- Added `CannedHttpResponse` and the `platform/testing.dart` library.
- Added response headers to `SeltzerHttpResponse`
