#include "CKSRootListController.h"

@implementation CKSRootListController

//Root.plistファイルを読み込ませて設定.appに反映させる
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)sourceLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/zunda-pixel/ChangeKeySound"] options:@{} completionHandler:nil];
}

- (void)respring {
    [HBRespringController respring];
}
@end
