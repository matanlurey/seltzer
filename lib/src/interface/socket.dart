import 'dart:async';
import 'dart:typed_data';

import 'package:seltzer/src/context.dart' as platform;

import 'package:seltzer/src/socket_impl.dart';
import 'package:stream_channel/stream_channel.dart';
import 'socket_message.dart';

/// Returns a connected [SeltzerWebSocket] to [url].
typedef SeltzerWebSocket SeltzerWebSocketProvider(String url);

/// A cross-platform [web socket](https://tools.ietf.org/html/rfc6455).
///
/// The socket must be opened before any data can be sent through it.  Clients
/// should close the socket when they are finished listening to its [onMessage]
/// stream.
///
/// ## Example Usage:
///     var socket = await SeltzerWebSocket.connect('ws://foo.com:9090');
///     socket.onMessage.listen(print);
///     await socket.sendString(stringData);
///     await socket.close();
abstract class SeltzerWebSocket {
  /// Connects to a web socket server at [url].
  ///
  /// Returns a [Future] that completes upon connecting.
  static SeltzerWebSocket connect(String url) => platform.connect(url);

  /// The stream of data received by this socket.
  ///
  /// This is always a broadcast stream.
  Stream<SeltzerMessage> get onMessage;

  /// An future that completes when the socket is closed.
  Future<SeltzerSocketClosedEvent> get onClose;

  /// Initiates closing this socket's connection.
  ///
  /// The returned future completes when all open close messages have been sent
  /// and all subscriptions have cancelled.  To determine when the socket itself
  /// truly closes, wait until [onClose] completes.
  ///
  /// Set the optional [code] and [reason] arguments to send close information
  /// to the remote peer.
  void close({int code, String reason});

  /// Sends bytes [data] to the remote peer.
  void sendBytes(ByteBuffer data);

  /// Sends string [data] to the remote peer.
  void sendString(String data);
}

/// Returned from [SeltzerWebSocket.onClose].
class SeltzerSocketClosedEvent {
  /// Code defining why the socket closed.
  final int code;

  /// Message why the socket closed.
  final String reason;

  const SeltzerSocketClosedEvent(this.code, [this.reason]);
}
