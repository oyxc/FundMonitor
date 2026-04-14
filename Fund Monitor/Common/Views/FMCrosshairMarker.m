//
//  FMCrosshairMarker.m
//  FundMonitor
//
//  自定义十字线标记视图
//

#import "FMCrosshairMarker.h"

@interface FMCrosshairMarker ()

@property (nonatomic, strong) UIView *infoContainer;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation FMCrosshairMarker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;  // 默认隐藏

    // 信息容器
    self.infoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
    self.infoContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.infoContainer.layer.cornerRadius = 4;
    [self addSubview:self.infoContainer];

    // 日期标签
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 110, 18)];
    self.dateLabel.font = [UIFont systemFontOfSize:12];
    self.dateLabel.textColor = [UIColor whiteColor];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.infoContainer addSubview:self.dateLabel];

    // 数值标签
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 110, 20)];
    self.valueLabel.font = [UIFont boldSystemFontOfSize:14];
    self.valueLabel.textColor = [UIColor whiteColor];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    [self.infoContainer addSubview:self.valueLabel];
}

- (void)updateWithValue:(double)value dateIndex:(NSInteger)index {
    // 更新数值
    self.valueLabel.text = [NSString stringWithFormat:@"%.4f", value];

    // 更新日期
    if (self.dateLabels && index >= 0 && index < self.dateLabels.count) {
        self.dateLabel.text = self.dateLabels[index];
    } else {
        self.dateLabel.text = @"--";
    }
}

- (void)showAtPoint:(CGPoint)point inView:(UIView *)view {
    CGFloat width = 120;
    CGFloat height = 50;

    // 计算位置，避免超出边界
    CGFloat x = point.x - width / 2;
    CGFloat y = point.y - height - 10;

    // 如果超出左边界
    if (x < 0) {
        x = point.x + 10;
    }
    // 如果超出右边界
    else if (x + width > view.bounds.size.width) {
        x = point.x - width - 10;
    }

    // 如果超出上边界
    if (y < 0) {
        y = point.y + 10;
    }

    self.frame = CGRectMake(x, y, width, height);
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

@end
