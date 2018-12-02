import 'dart:async';

import 'package:flutter/services.dart';

class AdvancedAudio {
  static const MethodChannel _channel =
      const MethodChannel('podl.io/advanced_audio');

  AdvancedAudio() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  dispose() {
    _isPlayingController.close();
  }

  Stream<bool> get isPlaying => _isPlayingController.stream;
  final _isPlayingController = StreamController<bool>();

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

  Future<void> _methodCallHandler(MethodCall call) async {
    print('Method invoked: ${call.method}');
    switch (call.method) {
      case "audio.onPlay":
        _isPlayingController.add(true);
        break;

      case "audio.onComplete":
        print("Completed audio");
        break;

      case "audio.onPause":
        print("Paused audio");
        break;

      case "audio.onStop":
        print("Stopped audio");
        break;

      case "audio.onRateChange":
        print("Changed rate for audio");
        break;

      default:
        throw new ArgumentError('Unknown method ${call.method} ');
    }
  }
}
