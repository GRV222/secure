import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenSecurity {
  static const _channel = MethodChannel('com.secure.secure/screen_security');

  static Future<void> enableMaxSecurity() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setSecure', {'enable': true});
    } catch (e) {
      debugPrint('Screen security enable error: $e');
    }
  }

  static Future<void> disableScreenSecurity() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setSecure', {'enable': false});
    } catch (e) {
      debugPrint('Screen security disable error: $e');
    }
  }
}
