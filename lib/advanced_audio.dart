import 'dart:async';

import 'package:flutter/services.dart';

class AdvancedAudio {
  static const MethodChannel _channel =
      const MethodChannel('podl.io/advanced_audio');

  static Future<int> pause() async {
    final int success = await _channel.invokeMethod('pause');
    return success;
  }
  
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> play(String url) async {
    final int success = await _channel.invokeMethod('play', <String, dynamic>{
      'url': url,
    });
    return success;
  }

  static Future<int> setRate(double rate) async {
    final int success =
        await _channel.invokeMethod('setRate', <String, dynamic>{
      'rate': rate,
    });
    return success;
  }

  static Future<int> stop() async {
    final int success = await _channel.invokeMethod('stop');
    return success;
  }

}
