package com.example.advancedaudio;

import java.io.IOException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.media.AudioManager;
import android.media.MediaPlayer;

/** AdvancedAudioPlugin */
public class AdvancedAudioPlugin implements MethodCallHandler {
  MediaPlayer mediaPlayer;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "podl.io/advanced_audio");
    channel.setMethodCallHandler(new AdvancedAudioPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("play")) {
      String url = call.argument("url");
      play(url);
      result.success(null);
    } else if (call.method.equals("pause")) {
      pause();
    } else if (call.method.equals("stop")) {
      stop();
    } else {
      result.notImplemented();
    }
  }

  private void pause() {
    mediaPlayer.pause();
  }

  private void stop() {
    mediaPlayer.stop();
    mediaPlayer.release();
    mediaPlayer = null;
  }

  private void play(String url) {
    if (mediaPlayer == null) {
      mediaPlayer = new MediaPlayer();
      mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);

      try {
        mediaPlayer.setDataSource(url);
        mediaPlayer.prepare();
      } catch (IOException e) {
        // TODO: handle exception.. this should send something back to the app
      }

      mediaPlayer.start();
    } else {
      mediaPlayer.start();
    }

  }
}
