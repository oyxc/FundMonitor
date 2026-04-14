//
//  FMPerformanceView.h
//  Fund Monitor
//
//  单位净值（业绩走势）视图
//

#import <UIKit/UIKit.h>

@class FMHistoryDataTableView;
@class FMNetWorthTrendData;

NS_ASSUME_NONNULL_BEGIN

@interface FMPerformanceView : UIView

// 历史数据表格视图
@property (nonatomic, strong, readonly) FMHistoryDataTableView *tableView;

// 显示更多按钮
@property (nonatomic, strong, readonly) UIButton *showMoreButton;

// 显示更多按钮点击回调
@property (nonatomic, copy) void(^showMoreButtonTappedBlock)(void);

// 更新表格数据
- (void)updateWithHistoryData:(NSArray<FMNetWorthTrendData *> *)historyData;

@end

NS_ASSUME_NONNULL_END
