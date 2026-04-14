//
//  FMListHeaderView.h
//  FundMonitor
//
//  列表头部视图
//

#import <UIKit/UIKit.h>
@class FMFund;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FMSortType) {
    FMSortTypeNone,
    FMSortTypeEstimate,
    FMSortTypeLatest,
    FMSortTypeProfit
};

@interface FMListHeaderView : UIView

@property (nonatomic, assign) FMSortType sortType;
@property (nonatomic, assign) BOOL ascending;
@property (nonatomic, copy) void(^onSortChanged)(FMSortType type);

@property (nonatomic, strong) FMFund *fund;

@end

NS_ASSUME_NONNULL_END
