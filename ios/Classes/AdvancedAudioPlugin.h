#import <Flutter/Flutter.h>

@interface AdvancedAudioPlugin : NSObject <FlutterPlugin>

- (void)play:(NSString *)url;
- (void)setRate:(float)rate;
- (void)pause;
- (void)stop;
-(void)onTimeInterval:(CMTime)time;

@end
