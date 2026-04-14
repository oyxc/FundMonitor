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

@end

NS_ASSUME_NONNULL_END
