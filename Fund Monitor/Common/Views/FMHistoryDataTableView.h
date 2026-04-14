//
//  FMHistoryDataTableView.h
//  FundMonitor
//
//  历史数据表格 - 显示历史净值数据列表
//

#import <UIKit/UIKit.h>

@class FMNetWorthTrendData;

NS_ASSUME_NONNULL_BEGIN

@interface FMHistoryDataTableView : UIView

// 历史数据
@property (nonatomic, strong) NSArray<FMNetWorthTrendData *> *historyData;

// 刷新表格
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
