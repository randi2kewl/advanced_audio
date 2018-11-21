import 'dart:async';

import 'package:flutter/services.dart';

class AdvancedAudio {
  static const MethodChannel _channel =
      const MethodChannel('podl.io/advanced_audio');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> get play async {
    final int success = await _channel.invokeMethod('play');
    return success;
  }
}
