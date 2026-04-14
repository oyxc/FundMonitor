//
//  FMAssetCardView.m
//  FundMonitor
//

#import "FMAssetCardView.h"

@interface FMAssetCardView ()

@property (nonatomic, strong) UILabel *assetTitleLabel;
@property (nonatomic, strong) UILabel *assetValueLabel;
@property (nonatomic, strong) UIButton *eyeButton;

@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) UILabel *profitTitleLabel;
@property (nonatomic, strong) UILabel *profitValueLabel;

@end

@implementation FMAssetCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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
    //self.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 8;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowRadius = 4;

    // 左侧：账户资产
    self.assetTitleLabel = [[UILabel alloc] init];
    self.assetTitleLabel.text = @"账户资产";
    self.assetTitleLabel.font = [UIFont systemFontOfSize:12];
    self.assetTitleLabel.textColor = [UIColor secondaryLabelColor];
    [self addSubview:self.assetTitleLabel];

    self.assetValueLabel = [[UILabel alloc] init];
    self.assetValueLabel.text = @"0.00";
    self.assetValueLabel.font = [UIFont boldSystemFontOfSize:24];
    self.assetValueLabel.textColor = [UIColor labelColor];
    [self addSubview:self.assetValueLabel];

    // 眼睛按钮
    self.eyeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.eyeButton setTitle:@"👁" forState:UIControlStateNormal];
    self.eyeButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.eyeButton addTarget:self action:@selector(eyeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.eyeButton];

    // 加载本地保存的眼睛按钮状态
    self.assetHidden = [[NSUserDefaults standardUserDefaults] boolForKey:@"FMAssetHidden"];

    // 右侧：切换按钮
    self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.switchButton setTitle:@"💰" forState:UIControlStateNormal];
    self.switchButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.switchButton addTarget:self action:@selector(switchButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.switchButton];

    // 右侧：当日收益（日期和标题合并）
    self.profitTitleLabel = [[UILabel alloc] init];
    self.profitTitleLabel.text = @"-- 估算总收益";
    self.profitTitleLabel.font = [UIFont systemFontOfSize:12];
    self.profitTitleLabel.textColor = [UIColor secondaryLabelColor];
    self.profitTitleLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.profitTitleLabel];

    self.profitValueLabel = [[UILabel alloc] init];
    self.profitValueLabel.text = @"+0.00";
    self.profitValueLabel.font = [UIFont boldSystemFontOfSize:24];
    self.profitValueLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.profitValueLabel];

    [self setupConstraints];
}

- (void)setupConstraints {
    self.assetTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.assetValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.eyeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.switchButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.profitTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.profitValueLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        // 账户资产标题
        [self.assetTitleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
        [self.assetTitleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],

        // 账户资产金额
        [self.assetValueLabel.topAnchor constraintEqualToAnchor:self.assetTitleLabel.bottomAnchor constant:6],
        [self.assetValueLabel.leadingAnchor constraintEqualToAnchor:self.assetTitleLabel.leadingAnchor],

        // 眼睛按钮
        [self.eyeButton.centerYAnchor constraintEqualToAnchor:self.assetTitleLabel.centerYAnchor],
        [self.eyeButton.leadingAnchor constraintEqualToAnchor:self.assetTitleLabel.trailingAnchor constant:8],
        [self.eyeButton.widthAnchor constraintEqualToConstant:30],
        [self.eyeButton.heightAnchor constraintEqualToConstant:30],

        // 切换按钮
        [self.switchButton.centerYAnchor constraintEqualToAnchor:self.profitTitleLabel.centerYAnchor],
        [self.switchButton.trailingAnchor constraintEqualToAnchor:self.profitTitleLabel.leadingAnchor constant:-4],
        [self.switchButton.widthAnchor constraintEqualToConstant:24],
        [self.switchButton.heightAnchor constraintEqualToConstant:24],

        // 当日收益标题（包含日期）
        [self.profitTitleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
        [self.profitTitleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],

        // 当日收益金额
        [self.profitValueLabel.topAnchor constraintEqualToAnchor:self.profitTitleLabel.bottomAnchor constant:6],
        [self.profitValueLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20]
    ]];
}

- (void)updateDateLabelWithTime:(NSString *)time {
    self.profitTitleLabel.text = [NSString stringWithFormat:@"%@ 估算总收益", time];
}

- (void)updateAssetData {
    // 更新眼睛按钮图标
    if (self.assetHidden) {
        [self.eyeButton setTitle:@"👁‍🗨" forState:UIControlStateNormal];
    } else {
        [self.eyeButton setTitle:@"👁" forState:UIControlStateNormal];
    }

    if (self.assetHidden) {
        self.assetValueLabel.text = @"****";
        self.profitValueLabel.text = @"****";
    } else {
        self.assetValueLabel.text = [NSString stringWithFormat:@"%.2f", self.totalAsset];

        // 根据切换状态显示金额或百分比
        if (self.showProfitAsRate) {
            // 显示百分比
            NSString *sign = self.todayProfitRate >= 0 ? @"+" : @"";
            self.profitValueLabel.text = [NSString stringWithFormat:@"%@%.2f%%", sign, self.todayProfitRate];
        } else {
            // 显示金额
            NSString *sign = self.todayProfit >= 0 ? @"+" : @"";
            self.profitValueLabel.text = [NSString stringWithFormat:@"%@%.2f", sign, self.todayProfit];
        }

        // 设置颜色
        double value = self.showProfitAsRate ? self.todayProfitRate : self.todayProfit;
        if (value > 0) {
            self.profitValueLabel.textColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0]; // 红色
        } else if (value < 0) {
            self.profitValueLabel.textColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0]; // 绿色
        } else {
            self.profitValueLabel.textColor = [UIColor grayColor];
        }
    }
}

- (void)switchButtonTapped {
    self.showProfitAsRate = !self.showProfitAsRate;

    // 更新按钮图标
    if (self.showProfitAsRate) {
        [self.switchButton setTitle:@"%" forState:UIControlStateNormal];
    } else {
        [self.switchButton setTitle:@"💰" forState:UIControlStateNormal];
    }

    [self updateAssetData];
}

- (void)eyeButtonTapped {
    self.assetHidden = !self.assetHidden;

    // 保存眼睛按钮状态到本地
    [[NSUserDefaults standardUserDefaults] setBool:self.assetHidden forKey:@"FMAssetHidden"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self updateAssetData];

    if (self.onEyeButtonTapped) {
        self.onEyeButtonTapped();
    }
}

- (void)setTotalAsset:(double)totalAsset {
    _totalAsset = totalAsset;
    [self updateAssetData];
}

- (void)setTodayProfit:(double)todayProfit {
    _todayProfit = todayProfit;
    [self updateAssetData];
}

- (void)setTodayProfitRate:(double)todayProfitRate {
    _todayProfitRate = todayProfitRate;
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.assetTitleLabel.textColor = [UIColor secondaryLabelColor];
    self.assetValueLabel.textColor = [UIColor labelColor];
    self.profitTitleLabel.textColor = [UIColor secondaryLabelColor];
    // profitValueLabel 的颜色由 updateAssetData 方法根据收益情况动态设置
}

@end
