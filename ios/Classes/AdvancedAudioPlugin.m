#import "AdvancedAudioPlugin.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

static AVPlayer *player;
static AVPlayerItem *playerItem;
static NSString *lastPlayedUrl;

@implementation AdvancedAudioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"podl.io/advanced_audio"
            binaryMessenger:[registrar messenger]];
  AdvancedAudioPlugin* instance = [[AdvancedAudioPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
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
      [self play:url];
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

- (void) play : (NSString*) url {
    if(player == nil || ![lastPlayedUrl isEqualToString:url]) {
      playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
      [playerItem addObserver:self forKeyPath:@"player.status" options:0 context:nil];
      player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    }
    
    [player play];

    lastPlayedUrl = url;
}

- (void) setRate : (float) newRate {
  if(player) {
    player.rate = newRate;
  }
}

- (void) pause {
  if(player) {
    [player pause];
  }
}

- (void) stop {
  if(player) {
    [player pause];
  }
}



@end
