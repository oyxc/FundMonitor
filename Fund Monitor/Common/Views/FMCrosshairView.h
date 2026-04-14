//
//  FMCrosshairView.h
//  FundMonitor
//
//  十字线覆盖视图
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMCrosshairView : UIView

// 设置十字线的交叉点
- (void)setCrosshairAtPoint:(CGPoint)point;

// 隐藏十字线
- (void)hideCrosshair;

@end

NS_ASSUME_NONNULL_END
