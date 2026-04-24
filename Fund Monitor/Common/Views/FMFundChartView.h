//
//  FMFundChartView.h
//  FundMonitor
//
//  图表视图 - 使用 DGCharts 显示基金净值走势
//

#import <UIKit/UIKit.h>

@class FMFundHistoryData;
@class FMNetWorthTrendData;
@class FMGrandTotalData;

NS_ASSUME_NONNULL_BEGIN

@interface FMFundChartView : UIView
// 选择走势图时的model
@property(nonatomic, copy) void(^selectBlock)(id _Nullable object);

// 净值走势数据（新格式）
@property (nonatomic, strong) NSArray<FMNetWorthTrendData *> *netWorthTrendData;

// 累计收益数据
@property (nonatomic, strong) NSArray<FMGrandTotalData *> *grandTotalData;

// 使用净值走势数据更新图表
- (void)updateChartWithNetWorthTrendData:(NSInteger)startTime;

// 使用累计收益数据更新图表
- (void)updateChartWithGrandTotalDataByCount:(NSInteger)showCount startTime:(NSInteger)startTime;

@end

NS_ASSUME_NONNULL_END
