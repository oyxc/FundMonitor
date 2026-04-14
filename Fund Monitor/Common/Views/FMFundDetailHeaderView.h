//
//  FMFundDetailHeaderView.h
//  FundMonitor
//
//  头部信息视图 - 显示当日涨幅、收益率、持有人数排名
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMFundDetailHeaderView : UIView

// 基金名称
@property (nonatomic, copy) NSString *fundName;

// 基金代码
@property (nonatomic, copy) NSString *fundCode;

// 基金类型（股票型、混合型等）
@property (nonatomic, copy) NSString *fundType;

// 当日涨幅（百分比）
@property (nonatomic, copy) NSString *todayRate;

// 近1年收益率（百分比）
@property (nonatomic, strong) NSNumber *yearRate;

// 更新显示
- (void)updateDisplay;

@end

NS_ASSUME_NONNULL_END
