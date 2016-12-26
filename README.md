# Seltzer

[![pub package](https://img.shields.io/pub/v/seltzer.svg)](https://pub.dartlang.org/packages/seltzer)
[![Build Status](https://travis-ci.org/matanlurey/seltzer.svg?branch=master)](https://travis-ci.org/matanlurey/seltzer)

An elegant and rich cross-platform HTTP library for Dart.

## Getting Started

You can use Seltzer as an object-oriented HTTP service _or_ simply use
top-level convenience methods like `get` and `post` directly.

### Using HTTP the service

If you are using Seltzer with dependency injection:

```dart
import 'dart:async';

import 'package:seltzer/seltzer.dart';
import 'package:seltzer/platform/vm.dart';

void main() {
  new MyTwitterService(const VmSeltzerHttp()).tweet('Hello World!');
}

class MyTwitterService {
  final SeltzerHttp _http;
  
  MyTwitterService(this._http);
  
  // Uses the SeltzerHttp service to send a tweet.
  //
  // This means if we are in the browser or the VM we can expect
  // our http service to work about the same.
  Future<Null> tweet(String message) => ...
}
```

### Using top-level methods

For simpler applications or scripts, Seltzer also provides a series of
top-level convenience methods that automatically use a singleton
instance of `SeltzerHttp`.

In your `main()` function, you just need to configure what platform you
are expecting once:

```dart
import 'package:seltzer/seltzer.dart' as seltzer;
import 'package:seltzer/platform/browser.dart';

main() async {
  useSeltzerInTheBrowser();
  final response = await seltzer.get('some/url.json').send().first;
  print('Retrieved: ${await response.readAsString()}');
}
```

### Using the WebSocket service

```dart
import 'dart:async';

import 'package:seltzer/seltzer.dart';
import 'package:seltzer/platform/vm.dart';

void main() {
  var service = new MyMessageService(connect('ws://127.0.0.1'));
  service.sendMessage('Hello World!');
}

class MyMessageService {
  final SeltzerWebSocket _webSocket;
   
  MyMessageService(this._webSocket);
  
  // Uses a SeltzerWebSocket to send a string message to a peer.
  //
  // This means if we are in the browser or the server we can expect
  // our WebSocket to work about the same.
  Future<Null> sendMessage(String message) => _webSocket.sendString(message);
}
```
