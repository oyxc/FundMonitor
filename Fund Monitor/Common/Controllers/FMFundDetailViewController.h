//
//  FMFundDetailViewController.h
//  FundMonitor
//
//  基金详情页面
//

#import <UIKit/UIKit.h>
#import "FMFund.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMFundDetailViewController : UIViewController

@property (nonatomic, strong) FMFund *fund;
@property (nonatomic, copy) NSString *groupId;  // 当前查看的分组ID

// 侧滑切换支持：传入完整列表和当前索引
@property (nonatomic, strong) NSArray<FMFund *> *fundList;
@property (nonatomic, assign) NSInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
