//
//  FMImportConfirmViewController.h
//  FundMonitor
//
//  导入基金确认页面
//

#import <UIKit/UIKit.h>

@class FMFund;

NS_ASSUME_NONNULL_BEGIN

@interface FMImportConfirmViewController : UIViewController

@property (nonatomic, strong) NSArray<FMFund *> *fundModels;  // 导入的基金列表
@property (nonatomic, copy) NSString *groupId;  // 目标分组ID

@end

NS_ASSUME_NONNULL_END
