//
//  FMListHeaderView.m
//  FundMonitor
//

#import "FMListHeaderView.h"
#import "FMFund.h"

@interface FMListHeaderView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *estimateButton;
@property (nonatomic, strong) UIButton *latestButton;
@property (nonatomic, strong) UIButton *profitButton;

@property (nonatomic, strong) UILabel *nameDateLabel;
@property (nonatomic, strong) UILabel *estimateDateLabel;
@property (nonatomic, strong) UILabel *latestDateLabel;
@property (nonatomic, strong) UILabel *profitDateLabel;

@end

@implementation FMListHeaderView

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

- (void)setFund:(FMFund *)fund
{
    _fund = fund;
    
    NSString *estimateTime = fund.estimateTime?:@"--";
    NSString *latestTime = fund.latestTime?:@"--";
    if (estimateTime.length > 5) {
        estimateTime = [estimateTime substringFromIndex:5];
    }
    if (latestTime.length > 5) {
        latestTime = [latestTime substringFromIndex:5];
    }
    
    self.estimateDateLabel.text = estimateTime;
    self.latestDateLabel.text = latestTime;    
    self.profitDateLabel.text = latestTime;
}

- (void)setupUI {
    self.backgroundColor = [UIColor systemGroupedBackgroundColor];

    // 第一行：列标题
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.text = @"基金名称";
    self.nameLabel.font = [UIFont systemFontOfSize:12];
    self.nameLabel.textColor = [UIColor secondaryLabelColor];
    [self addSubview:self.nameLabel];

    self.estimateButton = [self createSortButtonWithTitle:@"估算净值↓" action:@selector(estimateButtonTapped)];
    [self addSubview:self.estimateButton];

    self.latestButton = [self createSortButtonWithTitle:@"最新净值↓" action:@selector(latestButtonTapped)];
    [self addSubview:self.latestButton];

    self.profitButton = [self createSortButtonWithTitle:@"持有收益↓" action:@selector(profitButtonTapped)];
    [self addSubview:self.profitButton];

    // 第二行：日期
    NSString *dateString = [self getCurrentDateString];

    self.nameDateLabel = [self createDateLabelWithText:@"金额"];
    [self addSubview:self.nameDateLabel];
    self.nameDateLabel.textAlignment = NSTextAlignmentLeft;

    self.estimateDateLabel = [self createDateLabelWithText:dateString];
    [self addSubview:self.estimateDateLabel];

    self.latestDateLabel = [self createDateLabelWithText:dateString];
    [self addSubview:self.latestDateLabel];

    self.profitDateLabel = [self createDateLabelWithText:dateString];
    [self addSubview:self.profitDateLabel];

    [self setupConstraints];
    
    //默认收益率排序
    [self profitButtonTapped];
}

- (UIButton *)createSortButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitleColor:[UIColor secondaryLabelColor] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)createDateLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentRight;
    return label;
}

- (NSString *)getCurrentDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd"];
    return [formatter stringFromDate:[NSDate date]];
}

- (void)setupConstraints {
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.estimateButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.latestButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.profitButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.estimateDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.latestDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.profitDateLabel.translatesAutoresizingMaskIntoConstraints = NO;

    CGFloat leftMargin = 15;
    CGFloat rightMargin = 15;
    CGFloat topMargin = 0;
    CGFloat bottomMargin = 5;

    [NSLayoutConstraint activateConstraints:@[
        // 第一行：列标题
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:topMargin],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:leftMargin],
        [self.nameLabel.heightAnchor constraintEqualToConstant:28],

        [self.estimateButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:topMargin],
        [self.estimateButton.leadingAnchor constraintEqualToAnchor:self.nameLabel.trailingAnchor constant:2],
        [self.estimateButton.heightAnchor constraintEqualToAnchor:self.nameLabel.heightAnchor constant:0],
        [self.estimateButton.widthAnchor constraintEqualToConstant:75],

        [self.latestButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:topMargin],
        [self.latestButton.leadingAnchor constraintEqualToAnchor:self.estimateButton.trailingAnchor constant:2],
        [self.latestButton.heightAnchor constraintEqualToAnchor:self.nameLabel.heightAnchor constant:0],
        [self.latestButton.widthAnchor constraintEqualToConstant:75],

        [self.profitButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:topMargin],
        [self.profitButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-rightMargin],
        [self.profitButton.leadingAnchor constraintEqualToAnchor:self.latestButton.trailingAnchor constant:2],
        [self.profitButton.heightAnchor constraintEqualToAnchor:self.nameLabel.heightAnchor constant:0],
        [self.profitButton.widthAnchor constraintEqualToConstant:75],

        // 第二行：日期
        [self.nameDateLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:-3],
        [self.nameDateLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        [self.nameDateLabel.widthAnchor constraintEqualToAnchor:self.nameLabel.widthAnchor],
        [self.nameDateLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-bottomMargin],

        [self.estimateDateLabel.topAnchor constraintEqualToAnchor:self.estimateButton.bottomAnchor constant:-3],
        [self.estimateDateLabel.leadingAnchor constraintEqualToAnchor:self.estimateButton.leadingAnchor],
        [self.estimateDateLabel.widthAnchor constraintEqualToAnchor:self.estimateButton.widthAnchor],

        [self.latestDateLabel.topAnchor constraintEqualToAnchor:self.latestButton.bottomAnchor constant:-3],
        [self.latestDateLabel.leadingAnchor constraintEqualToAnchor:self.latestButton.leadingAnchor],
        [self.latestDateLabel.widthAnchor constraintEqualToAnchor:self.latestButton.widthAnchor],

        [self.profitDateLabel.topAnchor constraintEqualToAnchor:self.profitButton.bottomAnchor constant:-3],
        [self.profitDateLabel.trailingAnchor constraintEqualToAnchor:self.profitButton.trailingAnchor],
        [self.profitDateLabel.leadingAnchor constraintEqualToAnchor:self.profitButton.leadingAnchor]
    ]];
}

- (void)estimateButtonTapped {
    if (self.sortType == FMSortTypeEstimate) {
        self.ascending = !self.ascending;
    } else {
        self.sortType = FMSortTypeEstimate;
        self.ascending = NO;
    }
    [self updateButtonStates];

    if (self.onSortChanged) {
        self.onSortChanged(self.sortType);
    }
}

- (void)latestButtonTapped {
    if (self.sortType == FMSortTypeLatest) {
        self.ascending = !self.ascending;
    } else {
        self.sortType = FMSortTypeLatest;
        self.ascending = NO;
    }
    [self updateButtonStates];

    if (self.onSortChanged) {
        self.onSortChanged(self.sortType);
    }
}

- (void)profitButtonTapped {
    if (self.sortType == FMSortTypeProfit) {
        self.ascending = !self.ascending;
    } else {
        self.sortType = FMSortTypeProfit;
        self.ascending = NO;
    }
    [self updateButtonStates];

    if (self.onSortChanged) {
        self.onSortChanged(self.sortType);
    }
}

- (void)updateButtonStates {
    NSString *arrow = self.ascending ? @"↑" : @"↓";

    [self.estimateButton setTitle:[NSString stringWithFormat:@"估算净值%@", self.sortType == FMSortTypeEstimate ? arrow : @""] forState:UIControlStateNormal];
    [self.latestButton setTitle:[NSString stringWithFormat:@"最新净值%@", self.sortType == FMSortTypeLatest ? arrow : @""] forState:UIControlStateNormal];
    [self.profitButton setTitle:[NSString stringWithFormat:@"持有收益%@", self.sortType == FMSortTypeProfit ? arrow : @""] forState:UIControlStateNormal];

    [self.estimateButton setTitleColor:self.sortType == FMSortTypeEstimate ? [UIColor systemBlueColor] : [UIColor secondaryLabelColor] forState:UIControlStateNormal];
    [self.latestButton setTitleColor:self.sortType == FMSortTypeLatest ? [UIColor systemBlueColor] : [UIColor secondaryLabelColor] forState:UIControlStateNormal];
    [self.profitButton setTitleColor:self.sortType == FMSortTypeProfit ? [UIColor systemBlueColor] : [UIColor secondaryLabelColor] forState:UIControlStateNormal];
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.nameLabel.textColor = [UIColor secondaryLabelColor];

    // 更新按钮颜色
    [self updateButtonStates];

    // 更新日期标签颜色
    self.nameDateLabel.textColor = [UIColor tertiaryLabelColor];
    self.estimateDateLabel.textColor = [UIColor tertiaryLabelColor];
    self.latestDateLabel.textColor = [UIColor tertiaryLabelColor];
    self.profitDateLabel.textColor = [UIColor tertiaryLabelColor];
}

@end
