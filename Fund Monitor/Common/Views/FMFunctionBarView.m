//
//  FMFunctionBarView.m
//  FundMonitor
//

#import "FMFunctionBarView.h"

@interface FMFunctionBarView ()

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *viewModeButton;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *sortButton;

@end

@implementation FMFunctionBarView

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
    self.backgroundColor = [UIColor systemBackgroundColor];

    // 设置按钮
    self.settingsButton = [self createButtonWithTitle:@"⚙️" action:@selector(settingsButtonTapped)];
    [self addSubview:self.settingsButton];

    // 视图模式按钮
    self.viewModeButton = [self createButtonWithTitle:@"📊" action:@selector(viewModeButtonTapped)];
    [self addSubview:self.viewModeButton];

    // 搜索按钮
    self.searchButton = [self createButtonWithTitle:@"🔍" action:@selector(searchButtonTapped)];
    [self addSubview:self.searchButton];

    // 排序按钮
    self.sortButton = [self createButtonWithTitle:@"≡" action:@selector(sortButtonTapped)];
    [self addSubview:self.sortButton];

    [self setupConstraints];
}

- (UIButton *)createButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:24];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setupConstraints {
    self.settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.viewModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.sortButton.translatesAutoresizingMaskIntoConstraints = NO;

    // 创建一个 StackView 来均匀分布按钮
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.settingsButton,
        self.viewModeButton,
        self.searchButton,
        self.sortButton
    ]];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stackView];

    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

        [self.settingsButton.widthAnchor constraintEqualToConstant:44],
        [self.settingsButton.heightAnchor constraintEqualToConstant:44],
        [self.viewModeButton.widthAnchor constraintEqualToConstant:44],
        [self.viewModeButton.heightAnchor constraintEqualToConstant:44],
        [self.searchButton.widthAnchor constraintEqualToConstant:44],
        [self.searchButton.heightAnchor constraintEqualToConstant:44],
        [self.sortButton.widthAnchor constraintEqualToConstant:44],
        [self.sortButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)settingsButtonTapped {
    if (self.onSettingsTapped) {
        self.onSettingsTapped();
    }
}

- (void)viewModeButtonTapped {
    if (self.onViewModeTapped) {
        self.onViewModeTapped();
    }
}

- (void)searchButtonTapped {
    if (self.onSearchTapped) {
        self.onSearchTapped();
    }
}

- (void)sortButtonTapped {
    if (self.onSortTapped) {
        self.onSortTapped();
    }
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.backgroundColor = [UIColor systemBackgroundColor];
}

@end
