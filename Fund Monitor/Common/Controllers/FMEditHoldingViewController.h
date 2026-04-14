//
//  FMEditHoldingViewController.h
//  FundMonitor
//
//  编辑持仓页面
//

#import <UIKit/UIKit.h>

@class FMFund;

NS_ASSUME_NONNULL_BEGIN

@interface FMEditHoldingViewController : UIViewController

@property (nonatomic, strong) FMFund *fund;
@property (nonatomic, copy) NSString *groupId;  // 当前编辑的分组ID

@end

NS_ASSUME_NONNULL_END
