#import "AdvancedAudioPlugin.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

static AVPlayer *player;
static AVPlayerItem *playerItem;
static NSString *lastPlayedUrl;
static FlutterMethodChannel *channel;

@implementation AdvancedAudioPlugin

FlutterMethodChannel *_channel;
NSMutableSet *timeobservers;
MPNowPlayingInfoCenter *infoCenter;
MPRemoteCommandCenter *commandCenter;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"podl.io/advanced_audio"
            binaryMessenger:[registrar messenger]];
  AdvancedAudioPlugin* instance = [[AdvancedAudioPlugin alloc] init];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

  [registrar addMethodCallDelegate:instance channel:channel];
    _channel = channel;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

  // Allow to continue playing while backgrounded and while hardware is silenced...
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

  typedef void (^CaseBlock)(void);

  NSDictionary *methods = @{
    @"getPlatformVersion" : ^{
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    },
    @"play" : ^{
      NSString *url = call.arguments[@"url"];
      int startTime = [call.arguments[@"startTime"] intValue];
      [self play:url atTime:startTime];
      result(nil);
    },
    @"setRate" : ^{
      float rate = [call.arguments[@"rate"] floatValue];
      [self setRate:rate];
      result(nil);
    },
    @"pause" : ^{
      [self pause];
      result(nil);
    },
    @"stop" : ^{
      [self stop];
      result(nil);
    },

  };

  CaseBlock c = methods[call.method];
  if (c) {
      c();
  } else {
      result(FlutterMethodNotImplemented);
  }
}

- (void) play: (NSString*)url atTime:(int)startTime {
    if(player == nil || ![lastPlayedUrl isEqualToString:url]) {
      playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
      // [playerItem addObserver:self forKeyPath:@"player.status" options:0 context:nil];

      player = [[AVPlayer alloc] initWithPlayerItem:playerItem];

      CMTime interval = CMTimeMakeWithSeconds(0.2, NSEC_PER_SEC);
      id timeObserver = [player addPeriodicTimeObserverForInterval:interval queue:nil usingBlock:^(CMTime time){
          [self onTimeInterval:time];
      }];
      [timeobservers addObject:timeObserver];
    }
    
    CMTime cmtStartTime = CMTimeMakeWithSeconds((double)startTime/1000, 1);
    [player seekToTime:cmtStartTime];
    
    [player play];
    
    [_channel invokeMethod:@"audio.onPlay" arguments:nil];

    NSMutableDictionary *songInfo = [NSMutableDictionary dictionary];
    [songInfo setValue:@"some title" forKey:MPMediaItemPropertyTitle];
    infoCenter.nowPlayingInfo = songInfo;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
              object:playerItem
               queue:nil
          usingBlock:^(NSNotification* notification){
              [self stop];
              [_channel invokeMethod:@"audio.onComplete" arguments:nil];
          }];


    lastPlayedUrl = url;
    [self setCommands];
}

- (void) setRate : (float) newRate {
  if(player) {
    player.rate = newRate;
  }
    [_channel invokeMethod:@"audio.onRateChange" arguments:nil];

}

- (void) pause {
  if(player) {
    [player pause];
  }
    [_channel invokeMethod:@"audio.onPause" arguments:nil];
}

- (void) stop {
  if(player) {
    [player pause];
  }
    [_channel invokeMethod:@"audio.onStop" arguments:nil];

}

- (void)onTimeInterval:(CMTime)time {
    int mseconds =  CMTimeGetSeconds(time)*1000;
    [_channel invokeMethod:@"audio.onCurrentPosition" arguments:@(mseconds)];
}

- (void)dealloc {
    for (id ob in timeobservers) {
        [player removeTimeObserver:ob];
    }
    timeobservers = nil;
}

- (void) setCommands {
    MPRemoteCommand *pauseCommand = [commandCenter pauseCommand];
    pauseCommand.enabled = true;
    [pauseCommand addTarget:self action:@selector(pauseCommand:)];
    
    MPRemoteCommand *playCommand = [commandCenter playCommand];
    playCommand.enabled = true;
    [playCommand addTarget:self action:@selector(playCommand:)];
}

- (void) pauseCommand:(MPRemoteCommandEvent *) event {
    [self pause];
}

- (void) playCommand:(MPRemoteCommandEvent *) event {
    [self play:lastPlayedUrl atTime:0];
}

@end
