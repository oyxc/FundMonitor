//
//  FMTopHoldingsView.h
//  FundMonitor
//
//  基金十大重仓视图
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMTopHoldingsView : UIView

@property (nonatomic, copy) NSString *fundCode;  // 基金代码
@property (nonatomic, copy) NSArray<NSString *> *stockCodesNew;  // 股票代码列表

// 直接使用股票代码加载行情（不需要再请求持仓数据）
- (void)loadHoldingsData;

@end

NS_ASSUME_NONNULL_END
