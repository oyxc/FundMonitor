//
//  FMHotFundHeaderView.m
//  FundMonitor
//

#import "FMHotFundHeaderView.h"

@interface FMHotFundHeaderView ()

@property (nonatomic, strong) UIButton *thisYearButton;
@property (nonatomic, strong) UIButton *month1Button;
@property (nonatomic, strong) UIButton *month6Button;
@property (nonatomic, strong) UIButton *year1Button;

@end

@implementation FMHotFundHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.filterType = FMHotFundFilterType1Year; // 默认显示近1年
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
    self.backgroundColor = [UIColor systemGroupedBackgroundColor];

    // 今年以来按钮
    self.thisYearButton = [self createFilterButtonWithTitle:@"今年" action:@selector(thisYearButtonTapped)];
    [self addSubview:self.thisYearButton];

    // 近1月按钮
    self.month1Button = [self createFilterButtonWithTitle:@"近1月" action:@selector(month1ButtonTapped)];
    [self addSubview:self.month1Button];

    // 近6月按钮
    self.month6Button = [self createFilterButtonWithTitle:@"近6月" action:@selector(month6ButtonTapped)];
    [self addSubview:self.month6Button];

    // 近1年按钮
    self.year1Button = [self createFilterButtonWithTitle:@"近1年" action:@selector(year1ButtonTapped)];
    [self addSubview:self.year1Button];

    [self setupConstraints];
    [self updateButtonStates];
}

- (UIButton *)createFilterButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitleColor:[UIColor secondaryLabelColor] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setupConstraints {
    self.thisYearButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.month1Button.translatesAutoresizingMaskIntoConstraints = NO;
    self.month6Button.translatesAutoresizingMaskIntoConstraints = NO;
    self.year1Button.translatesAutoresizingMaskIntoConstraints = NO;

    CGFloat leftMargin = 0;
    CGFloat rightMargin = 0;
    CGFloat topMargin = 0;
    CGFloat heightMargin = 38;

    [NSLayoutConstraint activateConstraints:@[
        // 今年以来按钮
        [self.thisYearButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:topMargin],
        [self.thisYearButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:leftMargin],
        [self.thisYearButton.heightAnchor constraintEqualToConstant:heightMargin],

        // 近1月按钮
        [self.month1Button.topAnchor constraintEqualToAnchor:self.topAnchor constant:topMargin],
        [self.month1Button.leadingAnchor constraintEqualToAnchor:self.thisYearButton.trailingAnchor],
        [self.month1Button.heightAnchor constraintEqualToAnchor:self.thisYearButton.heightAnchor],
        [self.month1Button.widthAnchor constraintEqualToAnchor:self.thisYearButton.widthAnchor],

        // 近6月按钮
        [self.month6Button.topAnchor constraintEqualToAnchor:self.topAnchor constant:topMargin],
        [self.month6Button.leadingAnchor constraintEqualToAnchor:self.month1Button.trailingAnchor],
        [self.month6Button.heightAnchor constraintEqualToAnchor:self.thisYearButton.heightAnchor],
        [self.month6Button.widthAnchor constraintEqualToAnchor:self.month1Button.widthAnchor],

        // 近1年按钮
        [self.year1Button.topAnchor constraintEqualToAnchor:self.topAnchor constant:topMargin],
        [self.year1Button.leadingAnchor constraintEqualToAnchor:self.month6Button.trailingAnchor],
        [self.year1Button.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-rightMargin],
        [self.year1Button.heightAnchor constraintEqualToAnchor:self.thisYearButton.heightAnchor],
        [self.year1Button.widthAnchor constraintEqualToAnchor:self.month6Button.widthAnchor]
    ]];
}

- (void)thisYearButtonTapped {
    self.filterType = FMHotFundFilterTypeThisYear;
    [self updateButtonStates];

    if (self.onFilterChanged) {
        self.onFilterChanged(self.filterType);
    }
}

- (void)month1ButtonTapped {
    self.filterType = FMHotFundFilterType1Month;
    [self updateButtonStates];

    if (self.onFilterChanged) {
        self.onFilterChanged(self.filterType);
    }
}

- (void)month6ButtonTapped {
    self.filterType = FMHotFundFilterType6Month;
    [self updateButtonStates];

    if (self.onFilterChanged) {
        self.onFilterChanged(self.filterType);
    }
}

- (void)year1ButtonTapped {
    self.filterType = FMHotFundFilterType1Year;
    [self updateButtonStates];

    if (self.onFilterChanged) {
        self.onFilterChanged(self.filterType);
    }
}

- (void)updateButtonStates {
    // 更新按钮颜色
    [self.thisYearButton setTitleColor:self.filterType == FMHotFundFilterTypeThisYear ? [UIColor systemBlueColor] : [UIColor secondaryLabelColor] forState:UIControlStateNormal];
    [self.month1Button setTitleColor:self.filterType == FMHotFundFilterType1Month ? [UIColor systemBlueColor] : [UIColor secondaryLabelColor] forState:UIControlStateNormal];
    [self.month6Button setTitleColor:self.filterType == FMHotFundFilterType6Month ? [UIColor systemBlueColor] : [UIColor secondaryLabelColor] forState:UIControlStateNormal];
    [self.year1Button setTitleColor:self.filterType == FMHotFundFilterType1Year ? [UIColor systemBlueColor] : [UIColor secondaryLabelColor] forState:UIControlStateNormal];

    // 更新按钮字体粗细
    self.thisYearButton.titleLabel.font = self.filterType == FMHotFundFilterTypeThisYear ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
    self.month1Button.titleLabel.font = self.filterType == FMHotFundFilterType1Month ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
    self.month6Button.titleLabel.font = self.filterType == FMHotFundFilterType6Month ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
    self.year1Button.titleLabel.font = self.filterType == FMHotFundFilterType1Year ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.backgroundColor = [UIColor systemGroupedBackgroundColor];

    // 更新按钮颜色
    [self updateButtonStates];
}

@end
