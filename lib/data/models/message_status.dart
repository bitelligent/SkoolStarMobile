/// Delivery state of a chat message on this device.
enum MessageStatus {
  /// Accepted by the server (or received from it).
  sent,

  /// Optimistic local message still waiting for the server.
  sending,

  /// The server did not accept it; the user can retry or discard.
  failed,
}
