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
  private MediaPlayer mediaPlayer;
  private final MethodChannel channel;
  private final Handler handler = new Handler();

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "podl.io/advanced_audio");
    channel.setMethodCallHandler(new AdvancedAudioPlugin(registrar, channel));
  }

  private AdvancedAudioPlugin(Registrar registrar, MethodChannel channel) {
    this.channel = channel;
    channel.setMethodCallHandler(this);
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
    channel.invokeMethod("audio.onPause", null);
  }

  private void stop() {
    mediaPlayer.stop();
    mediaPlayer.release();
    mediaPlayer = null;
    channel.invokeMethod("audio.onStop", null);
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

    channel.invokeMethod("audio.onPlay", null);
    handler.send(sendData);
  }

  private final Runnable sendData = new Runnable(){
    public void run(){
      try {
        if (!mediaPlayer.isPlaying()) {
          handler.removeCallbacks(sendData);
        }
        int time = mediaPlayer.getCurrentPosition();
        channel.invokeMethod("audio.onCurrentPosition", time);
        handler.postDelayed(this, 200);
      }
      catch (Exception e) {
        Log.w(ID, "When running handler", e);
      }
    }
  };


}
