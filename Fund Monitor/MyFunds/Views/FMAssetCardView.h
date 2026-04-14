//
//  FMAssetCardView.h
//  FundMonitor
//
//  资产卡片视图
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMAssetCardView : UIView

@property (nonatomic, assign) double totalAsset;        // 总资产
@property (nonatomic, assign) double todayProfit;       // 当日收益
@property (nonatomic, assign) double todayProfitRate;   // 当日收益率
@property (nonatomic, assign) BOOL assetHidden;         // 是否隐藏资产
@property (nonatomic, assign) BOOL showProfitAsRate;    // 是否显示为百分比

// 更新资产数据
- (void)updateAssetData;
- (void)updateDateLabelWithTime:(NSString *)time;

// 眼睛按钮点击回调
@property (nonatomic, copy) void(^onEyeButtonTapped)(void);

@end

NS_ASSUME_NONNULL_END
