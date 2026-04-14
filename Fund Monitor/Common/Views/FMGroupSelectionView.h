//
//  FMGroupSelectionView.h
//  FundMonitor
//
//  底部分组选择弹窗
//

#import <UIKit/UIKit.h>
#import "FMGroup.h"
#import "FMFund.h"

NS_ASSUME_NONNULL_BEGIN

@class FMGroupSelectionView;

@protocol FMGroupSelectionViewDelegate <NSObject>

- (void)groupSelectionFinishWithMessage:(NSString *)message;

@end

@interface FMGroupSelectionView : UIView

@property (nonatomic, weak) id<FMGroupSelectionViewDelegate> delegate;

- (instancetype)initWithGroups:(NSArray<FMGroup *> *)groups fund:(FMFund *)fund selectedGroupIds:(NSSet<NSString *> *)selectedIds;
- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
