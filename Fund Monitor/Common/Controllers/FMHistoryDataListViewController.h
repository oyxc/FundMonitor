//
//  FMHistoryDataListViewController.h
//  Fund Monitor
//
//  历史数据列表页面 - 显示全部历史净值数据
//

#import <UIKit/UIKit.h>

@class FMNetWorthTrendData;

NS_ASSUME_NONNULL_BEGIN

@interface FMHistoryDataListViewController : UIViewController

// 历史数据数组
@property (nonatomic, strong) NSArray<FMNetWorthTrendData *> *historyData;

@end

NS_ASSUME_NONNULL_END
