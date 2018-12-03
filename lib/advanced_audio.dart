import 'dart:async';

import 'package:flutter/services.dart';

enum PlayerStatus {
  PLAYING,
  STOPPED,
  PAUSED,
  COMPLETED,
}

class AdvancedAudio {
  static const MethodChannel _channel =
      const MethodChannel('podl.io/advanced_audio');

  AdvancedAudio() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  dispose() {
    _playerStatusController.close();
    _isCompletedController.close();
    _currentPositionController.close();
  }

  Stream<PlayerStatus> get playerStatus => _playerStatusController.stream;
  final _playerStatusController = StreamController<PlayerStatus>();

  Stream<bool> get isCompleted => _isCompletedController.stream;
  final _isCompletedController = StreamController.broadcast();

  Duration _duration = const Duration();
  Duration get duration => _duration;

  Stream<Duration> get currentPosition => _currentPositionController.stream;
  final StreamController<Duration> _currentPositionController =
      StreamController.broadcast();

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
    switch (call.method) {
      case "audio.onPlay":
        _playerStatusController.add(PlayerStatus.PLAYING);
        _currentPositionController.add(Duration(milliseconds: 0));
        break;

      case "audio.onComplete":
        _playerStatusController.add(PlayerStatus.COMPLETED);
        break;

      case "audio.onPause":
        _playerStatusController.add(PlayerStatus.PAUSED);
        break;

      case "audio.onStop":
        _playerStatusController.add(PlayerStatus.STOPPED);
        break;

      case "audio.onRateChange":
        print("Changed rate for audio");
        break;

      case "audio.onCurrentPosition":
        _currentPositionController
            .add(new Duration(milliseconds: call.arguments));
        _duration = Duration(milliseconds: call.arguments);
        break;

      default:
        throw new ArgumentError('Unknown method ${call.method} ');
    }
  }
}
