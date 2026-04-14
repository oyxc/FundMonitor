//
//  FMFundDetailHeaderView.m
//  FundMonitor
//
//  头部信息视图 - 显示当日涨幅、收益率、基金类型
//

#import "FMFundDetailHeaderView.h"

@interface FMFundDetailHeaderView ()

@property (nonatomic, strong) UILabel *fundNameLabel;
@property (nonatomic, strong) UILabel *fundCodeLabel;
@property (nonatomic, strong) UILabel *todayRateTitleLabel;
@property (nonatomic, strong) UILabel *todayRateValueLabel;
@property (nonatomic, strong) UILabel *yearRateTitleLabel;
@property (nonatomic, strong) UILabel *yearRateValueLabel;
@property (nonatomic, strong) UILabel *holderRankTitleLabel;
@property (nonatomic, strong) UILabel *holderRankValueLabel;

@end

@implementation FMFundDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor systemBackgroundColor];
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = YES;

    // 基金名称 - 最顶部
    self.fundNameLabel = [[UILabel alloc] init];
    self.fundNameLabel.text = @"--";
    self.fundNameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.fundNameLabel.textColor = [UIColor labelColor];
    self.fundNameLabel.numberOfLines = 2;
    self.fundNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.fundNameLabel];

    // 基金代码 - 名称下方
    self.fundCodeLabel = [[UILabel alloc] init];
    self.fundCodeLabel.text = @"--";
    self.fundCodeLabel.font = [UIFont systemFontOfSize:14];
    self.fundCodeLabel.textColor = [UIColor secondaryLabelColor];
    self.fundCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.fundCodeLabel];

    // 当日涨幅 - 左侧
    self.todayRateTitleLabel = [[UILabel alloc] init];
    self.todayRateTitleLabel.text = @"当日涨幅";
    self.todayRateTitleLabel.font = [UIFont systemFontOfSize:14];
    self.todayRateTitleLabel.textColor = [UIColor secondaryLabelColor];
    self.todayRateTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.todayRateTitleLabel];

    self.todayRateValueLabel = [[UILabel alloc] init];
    self.todayRateValueLabel.text = @"--";
    self.todayRateValueLabel.font = [UIFont boldSystemFontOfSize:24];
    self.todayRateValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.todayRateValueLabel];

    // 近1年收益率 - 中间
    self.yearRateTitleLabel = [[UILabel alloc] init];
    self.yearRateTitleLabel.text = @"近1年";
    self.yearRateTitleLabel.font = [UIFont systemFontOfSize:14];
    self.yearRateTitleLabel.textColor = [UIColor secondaryLabelColor];
    self.yearRateTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.yearRateTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.yearRateTitleLabel];

    self.yearRateValueLabel = [[UILabel alloc] init];
    self.yearRateValueLabel.text = @"--";
    self.yearRateValueLabel.font = [UIFont boldSystemFontOfSize:18];
    self.yearRateValueLabel.textAlignment = NSTextAlignmentCenter;
    self.yearRateValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.yearRateValueLabel];

    // 基金类型 - 右侧
    self.holderRankTitleLabel = [[UILabel alloc] init];
    self.holderRankTitleLabel.text = @"基金类型";
    self.holderRankTitleLabel.font = [UIFont systemFontOfSize:14];
    self.holderRankTitleLabel.textColor = [UIColor secondaryLabelColor];
    self.holderRankTitleLabel.textAlignment = NSTextAlignmentRight;
    self.holderRankTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.holderRankTitleLabel];

    self.holderRankValueLabel = [[UILabel alloc] init];
    self.holderRankValueLabel.text = @"--";
    self.holderRankValueLabel.font = [UIFont boldSystemFontOfSize:18];
    self.holderRankValueLabel.textAlignment = NSTextAlignmentRight;
    self.holderRankValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.holderRankValueLabel];

    // 布局约束
    [NSLayoutConstraint activateConstraints:@[
        // 基金名称
        [self.fundNameLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
        [self.fundNameLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.fundNameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],

        // 基金代码
        [self.fundCodeLabel.topAnchor constraintEqualToAnchor:self.fundNameLabel.bottomAnchor constant:5],
        [self.fundCodeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.fundCodeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],

        // 当日涨幅标题
        [self.todayRateTitleLabel.topAnchor constraintEqualToAnchor:self.fundCodeLabel.bottomAnchor constant:15],
        [self.todayRateTitleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],

        // 当日涨幅数值
        [self.todayRateValueLabel.topAnchor constraintEqualToAnchor:self.todayRateTitleLabel.bottomAnchor constant:8],
        [self.todayRateValueLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.todayRateValueLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:-15],
        [self.todayRateValueLabel.heightAnchor constraintEqualToConstant:22],

        // 近1年标题
        [self.yearRateTitleLabel.topAnchor constraintEqualToAnchor:self.fundCodeLabel.bottomAnchor constant:15],
        [self.yearRateTitleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],

        // 近1年数值
        [self.yearRateValueLabel.topAnchor constraintEqualToAnchor:self.yearRateTitleLabel.bottomAnchor constant:8],
        [self.yearRateValueLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.yearRateValueLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:-15],
        [self.yearRateValueLabel.heightAnchor constraintEqualToConstant:22],

        // 基金类型标题
        [self.holderRankTitleLabel.topAnchor constraintEqualToAnchor:self.fundCodeLabel.bottomAnchor constant:15],
        [self.holderRankTitleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],

        // 基金类型数值
        [self.holderRankValueLabel.topAnchor constraintEqualToAnchor:self.holderRankTitleLabel.bottomAnchor constant:8],
        [self.holderRankValueLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
        [self.holderRankValueLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
        [self.holderRankValueLabel.heightAnchor constraintEqualToConstant:22],
    ]];
}

- (void)updateDisplay {
    // 更新基金名称
    if (self.fundName && self.fundName.length > 0) {
        self.fundNameLabel.text = self.fundName;
    } else {
        self.fundNameLabel.text = @"--";
    }

    // 更新基金代码
    if (self.fundCode && self.fundCode.length > 0) {
        self.fundCodeLabel.text = [NSString stringWithFormat:@"代码: %@", self.fundCode];
    } else {
        self.fundCodeLabel.text = @"--";
    }

    // 更新当日涨幅
    if (self.todayRate) {
        double rate = [self.todayRate doubleValue];
        NSString *sign = rate >= 0 ? @"+" : @"";
        self.todayRateValueLabel.text = [NSString stringWithFormat:@"%@%.2f%%", sign, rate];

        if (rate > 0) {
            self.todayRateValueLabel.textColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];  // 红色（涨）
        } else if (rate < 0) {
            self.todayRateValueLabel.textColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0];  // 绿色（跌）
        } else {
            self.todayRateValueLabel.textColor = [UIColor labelColor];
        }
    } else {
        self.todayRateValueLabel.text = @"--";
        self.todayRateValueLabel.textColor = [UIColor labelColor];
    }

    // 更新近1年收益率
    if (self.yearRate) {
        double rate = [self.yearRate doubleValue];
        NSString *sign = rate >= 0 ? @"+" : @"";
        self.yearRateValueLabel.text = [NSString stringWithFormat:@"%@%.2f%%", sign, rate];

        if (rate > 0) {
            self.yearRateValueLabel.textColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
        } else if (rate < 0) {
            self.yearRateValueLabel.textColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0];
        } else {
            self.yearRateValueLabel.textColor = [UIColor labelColor];
        }
    } else {
        self.yearRateValueLabel.text = @"--";
        self.yearRateValueLabel.textColor = [UIColor labelColor];
    }

    // 更新基金类型
    if (self.fundType) {
        self.holderRankValueLabel.text = self.fundType;
        self.holderRankValueLabel.textColor = [UIColor labelColor];
    } else {
        self.holderRankValueLabel.text = @"--";
        self.holderRankValueLabel.textColor = [UIColor labelColor];
    }
}

@end
