#import <AVFoundation/AVFoundation.h>
#import "Tweak.h"

HBPreferences *preferences;

// 設定アプリから値をセットするもの
bool enabled				= false;
bool isCustomSound			= false;
CGFloat volume				= 1.0;
NSString *selectedPreset	= @"";
NSString *customSoundName	= @"";


@interface UIKeyboardLayoutStar : UIView
@property (nonatomic, retain) AVAudioPlayer* player;
@end

%group Tweak
%hook UIKeyboardLayoutStar

// UIKeyboardLayoutStarにAVAudioPlayerのpropertyがないため追加
%property (nonatomic, retain) AVAudioPlayer* player;

-(instancetype)initWithFrame:(CGRect)frame {
    if (self == %orig) {
		// キーボードのタッチを防がないために新たなUITapGestureRecognizerを追加
		UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onKeyboardTouch:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:gestureRecognizer];

		NSString *path = @"";
		NSString *selectedSoundName = @"";

		if(isCustomSound){
			path = @"/var/mobile/Documents/";
			selectedSoundName = customSoundName;
		}
		else{
			path = @"/Library/Application Support/ChangeKeySound/";
			NSError *error=nil;
			NSFileManager *filemanager = [NSFileManager defaultManager];
			NSArray *files = [filemanager contentsOfDirectoryAtPath:path error:&error];
			selectedSoundName = files[[selectedPreset intValue]];
		}
		
		NSString* fullPath = [NSString stringWithFormat:@"%@%@", path, selectedSoundName];
		NSURL* fileURL = [NSURL fileURLWithPath:fullPath];

		self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
		self.player.volume = volume;
     }
     return self;

}

%new
-(void)onKeyboardTouch:(UITapGestureRecognizer *)gestureRecognizer {
	self.player.currentTime = 0;
	[self.player prepareToPlay];
	[self.player play];    
}
%end

%end


void loadPrefs() {
	preferences = [[HBPreferences alloc] initWithIdentifier:@"com.zunda.changekeysound"];
	[preferences registerBool:&enabled default:NO forKey:@"enabled"];
	[preferences registerBool:&isCustomSound default:NO forKey:@"isCustomSound"];
	[preferences registerObject:&selectedPreset default:@"0" forKey:@"selectedSound"];
	[preferences registerFloat:&volume default:1.0 forKey:@"volume"];
	[preferences registerObject:&customSoundName default:@"" forKey:@"customSoundName"];
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)loadPrefs,
									(CFStringRef)@"com.zunda.changekeysound/ReloadPrefs",
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately);

	loadPrefs();
	if(enabled) {%init(Tweak);}
}