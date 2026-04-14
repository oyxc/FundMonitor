//
//  FMFundCell.m
//  FundMonitor
//

#import "FMFundCell.h"

@interface FMFundCell ()

// 第一列：基金名称 + 持有金额
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *holdAmountLabel;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UILabel *noLabel;

// 第二列：估算涨跌幅 + 估算净值
@property (nonatomic, strong) UILabel *estimateRateLabel;
@property (nonatomic, strong) UILabel *estimateValueLabel;

// 第三列：最新涨跌幅 + 最新净值
@property (nonatomic, strong) UILabel *latestRateLabel;
@property (nonatomic, strong) UILabel *latestValueLabel;

// 第四列：持有收益 + 收益率
@property (nonatomic, strong) UILabel *holdProfitLabel;
@property (nonatomic, strong) UILabel *holdProfitRateLabel;

@end

@implementation FMFundCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];

        // 监听主题变更
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appearanceSettingDidChange)
                                                     name:@"AppearanceSettingDidChange"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor systemBackgroundColor];

    // 第一列：基金名称 + 持有金额
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:13];
    self.nameLabel.textColor = [UIColor labelColor];
    self.nameLabel.numberOfLines = 1;
    [self.contentView addSubview:self.nameLabel];

    self.codeLabel = [[UILabel alloc] init];
    self.codeLabel.font = [UIFont systemFontOfSize:10];
    self.codeLabel.textColor = [UIColor tertiaryLabelColor];
    [self.contentView addSubview:self.codeLabel];
    
    self.holdAmountLabel = [[UILabel alloc] init];
    self.holdAmountLabel.font = [UIFont systemFontOfSize:12];
    self.holdAmountLabel.textColor = [UIColor labelColor];
    [self.contentView addSubview:self.holdAmountLabel];
    
    self.noLabel = [[UILabel alloc] init];
    self.noLabel.font = [UIFont systemFontOfSize:9];
    self.noLabel.textColor = [UIColor labelColor];
    self.noLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.noLabel];

    // 第二列：估算涨跌幅 + 估算净值
    self.estimateRateLabel = [[UILabel alloc] init];
    self.estimateRateLabel.font = [UIFont systemFontOfSize:14];
    self.estimateRateLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.estimateRateLabel];
    
    self.estimateValueLabel = [[UILabel alloc] init];
    self.estimateValueLabel.font = [UIFont systemFontOfSize:10];
    self.estimateValueLabel.textAlignment = NSTextAlignmentRight;
    self.estimateValueLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.estimateValueLabel];

    // 第三列：最新涨跌幅 + 最新净值
    self.latestRateLabel = [[UILabel alloc] init];
    self.latestRateLabel.font = [UIFont systemFontOfSize:14];
    self.latestRateLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.latestRateLabel];
    
    self.latestValueLabel = [[UILabel alloc] init];
    self.latestValueLabel.font = [UIFont systemFontOfSize:10];
    self.latestValueLabel.textAlignment = NSTextAlignmentRight;
    self.latestValueLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.latestValueLabel];

    

    // 第四列：持有收益 + 收益率
    self.holdProfitLabel = [[UILabel alloc] init];
    self.holdProfitLabel.font = [UIFont systemFontOfSize:14];
    self.holdProfitLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.holdProfitLabel];
    
    self.holdProfitRateLabel = [[UILabel alloc] init];
    self.holdProfitRateLabel.font = [UIFont systemFontOfSize:12];
    self.holdProfitRateLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.holdProfitRateLabel];

    [self setupConstraints];
}

- (void)setupConstraints {
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.holdAmountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.noLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.estimateValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.estimateRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.latestValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.latestRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.holdProfitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.holdProfitRateLabel.translatesAutoresizingMaskIntoConstraints = NO;

    CGFloat leftMargin = 15;
    CGFloat rightMargin = 15;
    CGFloat columnSpacing = 2;

    [NSLayoutConstraint activateConstraints:@[
        // 第一列：基金名称（第一行）
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:leftMargin],

        // 第一列：持有金额（第二行）
//        [self.codeLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:3],
//        [self.codeLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        //[self.holdAmountLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:70],
        [self.holdAmountLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        [self.holdAmountLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:3],
        [self.holdAmountLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
        
        //no
        [self.noLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:2],
        [self.noLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0],

        // 第二列 估算涨跌幅（第一行）
        [self.estimateRateLabel.centerYAnchor constraintEqualToAnchor:self.nameLabel.centerYAnchor],
        [self.estimateRateLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.trailingAnchor constant:columnSpacing],
        [self.estimateRateLabel.widthAnchor constraintEqualToConstant:75],

        // 第二列：估算净值（第二行）
        [self.estimateValueLabel.centerYAnchor constraintEqualToAnchor:self.holdAmountLabel.centerYAnchor],
        [self.estimateValueLabel.leadingAnchor constraintEqualToAnchor:self.estimateRateLabel.leadingAnchor],
        [self.estimateValueLabel.widthAnchor constraintEqualToAnchor:self.estimateRateLabel.widthAnchor],
        
        //code
//        [self.codeLabel.trailingAnchor constraintEqualToAnchor:self.estimateValueLabel.leadingAnchor constant:-2],
//        [self.codeLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0],

        // 第三列：最新涨跌幅（第一行）
        [self.latestRateLabel.centerYAnchor constraintEqualToAnchor:self.nameLabel.centerYAnchor],
        [self.latestRateLabel.leadingAnchor constraintEqualToAnchor:self.estimateRateLabel.trailingAnchor constant:columnSpacing],
        [self.latestRateLabel.widthAnchor constraintEqualToConstant:75],

        // 第三列：最新净值（第二行）
        [self.latestValueLabel.centerYAnchor constraintEqualToAnchor:self.holdAmountLabel.centerYAnchor],
        [self.latestValueLabel.leadingAnchor constraintEqualToAnchor:self.latestRateLabel.leadingAnchor],
        [self.latestValueLabel.widthAnchor constraintEqualToAnchor:self.latestRateLabel.widthAnchor],

        // 第四列：持有收益（第一行）
        [self.holdProfitLabel.centerYAnchor constraintEqualToAnchor:self.nameLabel.centerYAnchor],
        [self.holdProfitLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-rightMargin],
        [self.holdProfitLabel.leadingAnchor constraintEqualToAnchor:self.latestRateLabel.trailingAnchor constant:columnSpacing],
        [self.holdProfitLabel.widthAnchor constraintEqualToConstant:75],

        // 第四列：收益率（第二行）
        [self.holdProfitRateLabel.centerYAnchor constraintEqualToAnchor:self.holdAmountLabel.centerYAnchor],
        [self.holdProfitRateLabel.trailingAnchor constraintEqualToAnchor:self.holdProfitLabel.trailingAnchor],
        [self.holdProfitRateLabel.leadingAnchor constraintEqualToAnchor:self.holdProfitLabel.leadingAnchor]
    ]];
}

- (void)setFund:(FMFund *)fund estimateTimeInt:(NSInteger)estimateTimeInt latestTimeInt:(NSInteger)latestTimeInt {
    _fund = fund;
    _codeLabel.text = fund.fundCode;
    
    NSString *estimateTimeString;
    if (estimateTimeInt != fund.estimateTimeInt) {
        estimateTimeString = fund.estimateTime;
        if (estimateTimeString.length > 5) {
            estimateTimeString = [estimateTimeString substringFromIndex:5];
        }
    }
    
    NSString *latestTimeString;
    if (latestTimeInt != fund.latestTimeInt) {
        latestTimeString = fund.latestTime;
        if (latestTimeString.length > 5) {
            latestTimeString = [latestTimeString substringFromIndex:5];
        }
    }

    //根据是否有持有净值显示背景色
    [self changeBgColor];

    // 第二列：估算涨跌幅 + 估算净值
    if (fund.estimateRate) {
        double rate = [fund.estimateRate doubleValue];
        NSString *sign = rate >= 0 ? @"+" : @"";
        self.estimateRateLabel.text = [NSString stringWithFormat:@"%@%.2f%%", sign, rate];
        self.estimateRateLabel.textColor = [self colorForRate:rate];
    } else {
        self.estimateRateLabel.text = @"--";
        self.estimateRateLabel.textColor = [UIColor grayColor];
    }
    
    if (fund.estimateValue) {
        if (estimateTimeString) {
            self.estimateValueLabel.text = [NSString stringWithFormat:@"%@ %.4f", estimateTimeString, [fund.estimateValue doubleValue]];
        } else {
            self.estimateValueLabel.text = [NSString stringWithFormat:@"%.4f", [fund.estimateValue doubleValue]];
        }
    } else {
        self.estimateValueLabel.text = @"--";
    }

    // 第三列：最新涨跌幅 + 最新净值
    if (fund.latestRate) {
        double rate = [fund.latestRate doubleValue];
        NSString *sign = rate >= 0 ? @"+" : @"";
        self.latestRateLabel.text = [NSString stringWithFormat:@"%@%.2f%%", sign, rate];
        self.latestRateLabel.textColor = [self colorForRate:rate];
    } else {
        self.latestRateLabel.text = @"--";
        self.latestRateLabel.textColor = [UIColor grayColor];
    }
    
    if (fund.latestValue) {
        if (latestTimeString) {
            self.latestValueLabel.text = [NSString stringWithFormat:@"%@ %.4f", latestTimeString, [fund.latestValue doubleValue]];
        } else {
            self.latestValueLabel.text = [NSString stringWithFormat:@"%.4f", [fund.latestValue doubleValue]];
        }
    } else {
        self.latestValueLabel.text = @"--";
    }

    // 第四列：持有收益 + 收益率（使用分组特定的数据）
    NSString *holdProfitRate = [fund holdProfitRateForGroup:self.groupId];
    if (holdProfitRate) {
        double rate = [holdProfitRate doubleValue];
        NSString *sign = rate >= 0 ? @"+" : @"";
        self.holdProfitRateLabel.text = [NSString stringWithFormat:@"%@%.2f%%", sign, rate];
        self.holdProfitRateLabel.textColor = [self colorForRate:rate];
    } else {
        self.holdProfitRateLabel.text = @"+0.00%";
        self.holdProfitRateLabel.textColor = [UIColor grayColor];
    }
    
    NSNumber *holdProfit = [fund holdProfitForGroup:self.groupId];
    if (holdProfit) {
        double profit = [holdProfit doubleValue];
        NSString *sign = profit >= 0 ? @"+" : @"";
        self.holdProfitLabel.text = [NSString stringWithFormat:@"%@%.2f", sign, profit];
        self.holdProfitLabel.textColor = [self colorForRate:profit];
    } else {
        self.holdProfitLabel.text = @"+0.00";
        self.holdProfitLabel.textColor = [UIColor grayColor];
    }
    
    // 第一列：基金名称 + 持有金额
    self.nameLabel.text = fund.fundName ?: @"--";
    
    // 使用分组特定的持有金额
    NSNumber *holdAmount = [fund holdAmountForGroup:self.groupId];
    if (holdAmount && holdAmount.doubleValue > 0) {
        self.holdAmountLabel.text = [NSString stringWithFormat:@"¥ %.2f", holdAmount.doubleValue + holdProfit.doubleValue];
    } else {
        self.holdAmountLabel.text = @"¥ 0.00";
    }
    
//    NSLog(@"%@ %@ %@",self.groupId,fund.fundName,holdProfitRate);
}

- (UIColor *)colorForRate:(double)rate {
    if (rate > 0) {
        return [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0]; // 红色
    } else if (rate < 0) {
        return [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0]; // 绿色
    } else {
        return [UIColor grayColor]; // 灰色
    }
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    [self changeBgColor];
    
    self.nameLabel.textColor = [UIColor labelColor];
    self.holdAmountLabel.textColor = [UIColor labelColor];
}

//根据是否有持有净值显示背景色
- (void)changeBgColor
{
    // 检查该分组是否有持仓净值，如果没有则显示橙色背景
    NSNumber *holdNetValue = [self.fund holdNetValueForGroup:self.groupId];
    BOOL hasHoldNetValue = holdNetValue && holdNetValue.doubleValue > 0;
    
    if (hasHoldNetValue) {
        self.contentView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        // 无持仓净值时显示橙色背景（表示需要补充持仓成本）
        self.contentView.backgroundColor = [UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:0.15];
    }
}

@end
