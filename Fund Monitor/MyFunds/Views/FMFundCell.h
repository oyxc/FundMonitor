//
//  FMFundCell.h
//  FundMonitor
//
//  基金列表Cell
//

#import <UIKit/UIKit.h>
#import "FMFund.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMFundCell : UITableViewCell
@property (nonatomic, strong, readonly) UILabel *noLabel;

@property (nonatomic, strong) FMFund *fund;
@property (nonatomic, copy) NSString *groupId;  // 当前显示的分组ID

- (void)setFund:(FMFund *)fund estimateTimeInt:(NSInteger)estimateTimeInt latestTimeInt:(NSInteger)latestTimeInt;

@end

NS_ASSUME_NONNULL_END
