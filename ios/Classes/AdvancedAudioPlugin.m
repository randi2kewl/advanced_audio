#import "AdvancedAudioPlugin.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

static AVPlayer *player;
static AVPlayerItem *playerItem;

@implementation AdvancedAudioPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"podl.io/advanced_audio"
            binaryMessenger:[registrar messenger]];
  AdvancedAudioPlugin* instance = [[AdvancedAudioPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

  typedef void (^CaseBlock)(void);

  NSDictionary *methods = @{
    @"getPlatformVersion" : ^{
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    },
    @"play" : ^{
      int success = [self play];
      result(@(success));
    },
  };

  CaseBlock c = methods[call.method];
  if (c) {
      c();
  } else {
      result(FlutterMethodNotImplemented);
  }
}

-(int)play {
    NSString *url = @"https://traffic.libsyn.com/secure/grumpyoldgeeks/298-Excelsior.mp3?dest-id=144134";
    
    playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
    [playerItem addObserver:self forKeyPath:@"player.status" options:0 context:nil];
    player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [player play];
    return 1;
}

@end
