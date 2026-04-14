//
//  FMCrosshairMarker.h
//  FundMonitor
//
//  自定义十字线标记视图
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMCrosshairMarker : UIView

// 日期标签数组（用于显示对应日期）
@property (nonatomic, strong) NSArray<NSString *> *dateLabels;

// 更新显示内容
- (void)updateWithValue:(double)value dateIndex:(NSInteger)index;

// 显示在指定位置
- (void)showAtPoint:(CGPoint)point inView:(UIView *)view;

// 隐藏
- (void)hide;

@end

NS_ASSUME_NONNULL_END
