//
//  FMCrosshairView.m
//  FundMonitor
//
//  十字线覆盖视图
//

#import "FMCrosshairView.h"

@interface FMCrosshairView ()

@property (nonatomic, assign) CGPoint crosshairPoint;
@property (nonatomic, assign) BOOL showCrosshair;

@end

@implementation FMCrosshairView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;  // 不拦截触摸事件
        self.showCrosshair = NO;
    }
    return self;
}

- (void)setCrosshairAtPoint:(CGPoint)point {
    self.crosshairPoint = point;
    self.showCrosshair = YES;
    [self setNeedsDisplay];
}

- (void)hideCrosshair {
    self.showCrosshair = NO;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    if (!self.showCrosshair) {
        return;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;

    // 设置虚线样式
    CGFloat dashPattern[] = {5, 5};
    CGContextSetLineDash(context, 0, dashPattern, 2);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor);

    // 绘制垂直虚线
    CGContextMoveToPoint(context, self.crosshairPoint.x, 0);
    CGContextAddLineToPoint(context, self.crosshairPoint.x, rect.size.height);
    CGContextStrokePath(context);

    // 绘制水平虚线
    CGContextMoveToPoint(context, 0, self.crosshairPoint.y);
    CGContextAddLineToPoint(context, rect.size.width, self.crosshairPoint.y);
    CGContextStrokePath(context);
}

@end
