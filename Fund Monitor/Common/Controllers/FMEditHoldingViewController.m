//
//  FMEditHoldingViewController.m
//  FundMonitor
//

#import "FMEditHoldingViewController.h"
#import "FMFund.h"
#import "FMDataManager.h"

@interface FMEditHoldingViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

// 基金信息显示
@property (nonatomic, strong) UILabel *fundNameLabel;
@property (nonatomic, strong) UILabel *fundCodeLabel;
@property (nonatomic, strong) UILabel *netValueLabel;

// 输入框
@property (nonatomic, strong) UITextField *holdAmountTextField;
@property (nonatomic, strong) UITextField *holdProfitTextField;

// 保存按钮
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation FMEditHoldingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"修改持仓";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    [self loadFundData];

    // 添加键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    // ScrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    // ContentView
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];

    // 基金名称
    self.fundNameLabel = [[UILabel alloc] init];
    self.fundNameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.fundNameLabel.textColor = [UIColor labelColor];
    self.fundNameLabel.numberOfLines = 0;
    self.fundNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.fundNameLabel];

    // 基金代码
    self.fundCodeLabel = [[UILabel alloc] init];
    self.fundCodeLabel.font = [UIFont systemFontOfSize:14];
    self.fundCodeLabel.textColor = [UIColor secondaryLabelColor];
    self.fundCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.fundCodeLabel];

    // 最新净值
    self.netValueLabel = [[UILabel alloc] init];
    self.netValueLabel.font = [UIFont systemFontOfSize:14];
    self.netValueLabel.textColor = [UIColor secondaryLabelColor];
    self.netValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.netValueLabel];

    // 持有金额输入框
    UIView *holdAmountView = [self createInputViewWithTitle:@"持有金额：" placeholder:@"请输入持有金额"];
    self.holdAmountTextField = (UITextField *)[holdAmountView viewWithTag:100];
    [self.contentView addSubview:holdAmountView];

    // 持有收益输入框
    UIView *holdProfitView = [self createInputViewWithTitle:@"持有收益：" placeholder:@"请输入持有收益"];
    self.holdProfitTextField = (UITextField *)[holdProfitView viewWithTag:100];
    [self.contentView addSubview:holdProfitView];

    // 保存按钮
    self.saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.saveButton setTitle:@"保存" forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.backgroundColor = [UIColor systemBlueColor];
    self.saveButton.layer.cornerRadius = 8;
    [self.saveButton addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.saveButton];

    // 布局
    [NSLayoutConstraint activateConstraints:@[
        // ScrollView
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        // ContentView
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],

        // 基金名称
        [self.fundNameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20],
        [self.fundNameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.fundNameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],

        // 基金代码
        [self.fundCodeLabel.topAnchor constraintEqualToAnchor:self.fundNameLabel.bottomAnchor constant:8],
        [self.fundCodeLabel.leadingAnchor constraintEqualToAnchor:self.fundNameLabel.leadingAnchor],

        // 最新净值
        [self.netValueLabel.topAnchor constraintEqualToAnchor:self.fundCodeLabel.bottomAnchor constant:8],
        [self.netValueLabel.leadingAnchor constraintEqualToAnchor:self.fundNameLabel.leadingAnchor],

        // 持有金额
        [holdAmountView.topAnchor constraintEqualToAnchor:self.netValueLabel.bottomAnchor constant:30],
        [holdAmountView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [holdAmountView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [holdAmountView.heightAnchor constraintEqualToConstant:60],

        // 持有收益
        [holdProfitView.topAnchor constraintEqualToAnchor:holdAmountView.bottomAnchor constant:20],
        [holdProfitView.leadingAnchor constraintEqualToAnchor:holdAmountView.leadingAnchor],
        [holdProfitView.trailingAnchor constraintEqualToAnchor:holdAmountView.trailingAnchor],
        [holdProfitView.heightAnchor constraintEqualToConstant:60],

        // 保存按钮
        [self.saveButton.topAnchor constraintEqualToAnchor:holdProfitView.bottomAnchor constant:40],
        [self.saveButton.leadingAnchor constraintEqualToAnchor:holdAmountView.leadingAnchor],
        [self.saveButton.trailingAnchor constraintEqualToAnchor:holdAmountView.trailingAnchor],
        [self.saveButton.heightAnchor constraintEqualToConstant:50],
        [self.saveButton.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-40]
    ]];
}

- (UIView *)createInputViewWithTitle:(NSString *)title placeholder:(NSString *)placeholder {
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    containerView.layer.cornerRadius = 8;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    // 防止 label 被拉伸
    [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [containerView addSubview:titleLabel];

    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    textField.font = [UIFont systemFontOfSize:18];
    textField.textColor = [UIColor labelColor];
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.delegate = self;
    textField.tag = 100;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:textField];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:15],
        [titleLabel.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor],

        [textField.leadingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor constant:10],
        [textField.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-15],
        [textField.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor]
    ]];

    return containerView;
}

- (void)loadFundData {
    if (!self.fund) {
        return;
    }

    // 显示基金信息
    self.fundNameLabel.text = self.fund.fundName;
    self.fundCodeLabel.text = self.fund.fundCode;

    // 显示最新净值和涨跌幅
    NSString *netValue = self.fund.latestValue ?: @"--";
    NSString *rate = self.fund.latestRate ?: @"--";
    self.netValueLabel.text = [NSString stringWithFormat:@"最新净值：%@ %@", netValue, rate];

    // 设置涨跌幅颜色
    if ([rate containsString:@"-"]) {
        self.netValueLabel.textColor = [UIColor systemGreenColor];
    } else if (![rate isEqualToString:@"--"] && ![rate isEqualToString:@"0.00%"]) {
        self.netValueLabel.textColor = [UIColor systemRedColor];
    }

    // 加载当前分组的持仓数据
    if (self.groupId) {
        CGFloat holdAmount = [[self.fund holdAmountForGroup:self.groupId] doubleValue];
        CGFloat holdProfit = [[self.fund holdProfitForGroup:self.groupId] doubleValue];

        if (holdAmount && holdAmount > 0) {
            self.holdAmountTextField.text = [NSString stringWithFormat:@"%.2f", holdAmount+holdProfit];
        }

        if (holdProfit && holdProfit != 0) {
            self.holdProfitTextField.text = [NSString stringWithFormat:@"%.2f", holdProfit];
        }
    }
}

- (void)saveAction {
    // 验证输入
    if (self.holdAmountTextField.text.length == 0) {
        [self showAlertWithMessage:@"请输入持有金额"];
        return;
    }

    if (self.holdProfitTextField.text.length == 0) {
        [self showAlertWithMessage:@"请输入持有收益"];
        return;
    }

    if (!self.groupId) {
        [self showAlertWithMessage:@"分组信息缺失"];
        return;
    }

    // 总金额
    CGFloat totalAmount = [self.holdAmountTextField.text doubleValue];
    // 持有收益
    CGFloat holdProfit = [self.holdProfitTextField.text doubleValue];
    // 持有本金
    CGFloat holdAmount = totalAmount - holdProfit;

    [self.fund setHoldAmount:@(holdAmount) forGroup:self.groupId];

    // 计算收益率
    double profitRate = 0;
    if (holdAmount > 0) {
        profitRate = holdProfit / holdAmount;
    }

    // 根据收益率和最新净值反推持仓净值（成本净值）
    if (self.fund.latestValue && [self.fund.latestValue doubleValue] > 0) {
        double latestValue = [self.fund.latestValue doubleValue];
        // 持仓净值 = 最新净值 / (1 + 收益率)
        double holdNetValue = latestValue / (1 + profitRate);
        [self.fund setHoldNetValue:@(holdNetValue) forGroup:self.groupId];
//        NSLog(@"计算持仓净值: 最新净值=%.4f, 收益率=%.2f%%, 持仓净值=%.4f", latestValue, profitRate*100, holdNetValue);
    }

    // 保存到数据库
    [[FMDataManager sharedManager] updateFund:self.fund];

    // 发送通知刷新列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FundDataDidUpdate" object:nil];

    // 返回上一页
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
