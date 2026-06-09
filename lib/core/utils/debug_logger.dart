class DebugLogger {
  DebugLogger._();

  static void log(String tag, String message) {
    // ignore: avoid_print
    print('[$tag] $message');
  }

  static void error(String tag, String message, [Object? error]) {
    // ignore: avoid_print
    print('[$tag] ERROR: $message${error != null ? ' | $error' : ''}');
  }
}
