//
//  FMHotFundHeaderView.h
//  FundMonitor
//
//  热门基金筛选头部视图
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FMHotFundFilterType) {
    FMHotFundFilterTypeThisYear,    // 今年以来
    FMHotFundFilterType1Month,      // 近1月
    FMHotFundFilterType6Month,      // 近6月
    FMHotFundFilterType1Year        // 近1年
};

@interface FMHotFundHeaderView : UIView

@property (nonatomic, assign) FMHotFundFilterType filterType;
@property (nonatomic, copy) void(^onFilterChanged)(FMHotFundFilterType type);

@end

NS_ASSUME_NONNULL_END
