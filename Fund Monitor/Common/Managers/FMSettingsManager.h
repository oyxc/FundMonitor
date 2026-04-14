//
//  FMSettingsManager.h
//  FundMonitor
//
//  配置管理器
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMSettingsManager : NSObject

+ (instancetype)sharedManager;

// 刷新频率（秒）
@property (nonatomic, assign) NSInteger refreshInterval;  // 1, 2, 3，默认2

// 肤色跟随系统
@property (nonatomic, assign) BOOL followSystemAppearance;  // 默认YES

// 保存和加载
- (void)saveSettings;
- (void)loadSettings;

@end

NS_ASSUME_NONNULL_END
