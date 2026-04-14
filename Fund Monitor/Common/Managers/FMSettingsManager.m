//
//  FMSettingsManager.m
//  FundMonitor
//
//  配置管理器实现
//

#import "FMSettingsManager.h"

static NSString *const kRefreshIntervalKey = @"RefreshInterval";
static NSString *const kFollowSystemAppearanceKey = @"FollowSystemAppearance";

@implementation FMSettingsManager

+ (instancetype)sharedManager {
    static FMSettingsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMSettingsManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSettings];
    }
    return self;
}

- (void)loadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // 刷新频率，默认2秒
    NSInteger interval = [defaults integerForKey:kRefreshIntervalKey];
    if (interval == 0) {
        self.refreshInterval = 2;  // 默认值
    } else {
        self.refreshInterval = interval;
    }

    // 肤色跟随系统，默认YES
    if ([defaults objectForKey:kFollowSystemAppearanceKey] == nil) {
        self.followSystemAppearance = YES;  // 默认值
    } else {
        self.followSystemAppearance = [defaults boolForKey:kFollowSystemAppearanceKey];
    }
}

- (void)saveSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.refreshInterval forKey:kRefreshIntervalKey];
    [defaults setBool:self.followSystemAppearance forKey:kFollowSystemAppearanceKey];
    [defaults synchronize];
}

@end
