// Import the framework which has the AVAudioPlayer class
#import <AVFoundation/AVFoundation.h>
#import "Tweak.h"

HBPreferences *preferences;
NSString* selectedPreset = @"0";
char* selectedSoundName = "";
bool enabled = false;
CGFloat volume = 1.0;

char soundFiles[14][50] = {
	"boyon1.mp3", 
	"bruhSound.mp3",
	"click1.mp3",
	"click2.mp3",
	"drum-japanese1.mp3",
	"electric-fan-off1.mp3",
	"electric-fan-on1.mp3",
	"eye-shine1.mp3",
	"keyboard1.mp3",
	"keyboard2.mp3",
	"pa.mp3",
	"pafu.mp3",
	"switch1.mp3",
	"typewriter1.mp3"
};

@interface UIKeyboardLayoutStar : UIView
@property (nonatomic, retain) AVAudioPlayer* player;
@end

%group Tweak
%hook UIKeyboardLayoutStar
// Add the property to the UIKeyboardLayoutStar class because it doesn't exist :DD
%property (nonatomic, retain) AVAudioPlayer* player;

-(instancetype)initWithFrame:(CGRect)frame {
    if ((self = %orig)) {
		// Add a UITapGestureRecognizer to the keyboard layout and do not let it block touches in the view
		UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onKeyboardTouch:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:gestureRecognizer];

		NSString* filePath = @"/Library/Application Support/ChangeKeySound/";
		selectedSoundName = soundFiles[[selectedPreset intValue]];
		NSString* NSselectedSoundName = [NSString stringWithCString: selectedSoundName encoding:NSUTF8StringEncoding];
		filePath = [NSString stringWithFormat:@"%@%@", filePath, NSselectedSoundName];
		NSURL* fileURL = [NSURL fileURLWithPath:filePath];
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
	[preferences registerObject:&selectedPreset default:@"0" forKey:@"selectedSound"];
	[preferences registerFloat:&volume default:1.0 forKey:@"volume"];
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
