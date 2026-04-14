//
//  FMHotFundCell.h
//  FundMonitor
//
//  热门基金列表 Cell
//

#import <UIKit/UIKit.h>

@class FMHotFundModel;

NS_ASSUME_NONNULL_BEGIN

@interface FMHotFundCell : UITableViewCell

@property (nonatomic, strong) FMHotFundModel *model;

@end

NS_ASSUME_NONNULL_END
