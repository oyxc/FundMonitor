//
//  FMFunctionBarView.h
//  FundMonitor
//
//  功能按钮栏
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMFunctionBarView : UIView

@property (nonatomic, copy) void(^onSettingsTapped)(void);
@property (nonatomic, copy) void(^onViewModeTapped)(void);
@property (nonatomic, copy) void(^onSearchTapped)(void);
@property (nonatomic, copy) void(^onSortTapped)(void);

@end

NS_ASSUME_NONNULL_END
