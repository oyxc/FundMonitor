//
//  FMImportConfirmViewController.m
//  FundMonitor
//
//  导入基金确认页面
//

#import "FMImportConfirmViewController.h"
#import "FMFund.h"
#import "FMDataManager.h"

@interface FMImportConfirmTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UILabel *holdAmountLabel;
@property (nonatomic, strong) UILabel *profitLabel;
@property (nonatomic, strong) UILabel *profitRateLabel;
@property (nonatomic, strong) UIButton *deleteButton;

// 删除按钮回调
@property (nonatomic, copy) void (^deleteButtonTapped)(void);

@end

@implementation FMImportConfirmTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 基金名称
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
    self.nameLabel.textColor = [UIColor labelColor];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.nameLabel];

    // 基金代码
    self.codeLabel = [[UILabel alloc] init];
    self.codeLabel.font = [UIFont systemFontOfSize:13];
    self.codeLabel.textColor = [UIColor secondaryLabelColor];
    self.codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.codeLabel];

    // 持有金额
    self.holdAmountLabel = [[UILabel alloc] init];
    self.holdAmountLabel.font = [UIFont systemFontOfSize:14];
    self.holdAmountLabel.textColor = [UIColor labelColor];
    self.holdAmountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.holdAmountLabel];

    // 持有收益
    self.profitLabel = [[UILabel alloc] init];
    self.profitLabel.font = [UIFont systemFontOfSize:14];
    self.profitLabel.textAlignment = NSTextAlignmentRight;
    self.profitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.profitLabel];

    // 收益率
    self.profitRateLabel = [[UILabel alloc] init];
    self.profitRateLabel.font = [UIFont systemFontOfSize:13];
    self.profitRateLabel.textAlignment = NSTextAlignmentRight;
    self.profitRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.profitRateLabel];

    // 删除按钮
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.deleteButton setImage:[UIImage systemImageNamed:@"trash"] forState:UIControlStateNormal];
    self.deleteButton.tintColor = [UIColor systemRedColor];
    self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deleteButton addTarget:self action:@selector(deleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deleteButton];

    // 布局
    [NSLayoutConstraint activateConstraints:@[
        // 基金名称
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.profitLabel.leadingAnchor constant:-8],

        // 基金代码
        [self.codeLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:4],
        [self.codeLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],

        // 持有金额
        [self.holdAmountLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:4],
        [self.holdAmountLabel.leadingAnchor constraintEqualToAnchor:self.codeLabel.trailingAnchor constant:20],
        [self.holdAmountLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],

        // 删除按钮
        [self.deleteButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.deleteButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [self.deleteButton.widthAnchor constraintEqualToConstant:44],
        [self.deleteButton.heightAnchor constraintEqualToConstant:44],

        // 持有收益
        [self.profitLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],
        [self.profitLabel.trailingAnchor constraintEqualToAnchor:self.deleteButton.leadingAnchor constant:-8],
        [self.profitLabel.widthAnchor constraintGreaterThanOrEqualToConstant:80],

        // 收益率
        [self.profitRateLabel.topAnchor constraintEqualToAnchor:self.profitLabel.bottomAnchor constant:4],
        [self.profitRateLabel.trailingAnchor constraintEqualToAnchor:self.profitLabel.trailingAnchor],
    ]];
}

- (void)configurWithFund:(FMFund *)fund groupId:(NSString *)groupId {
    self.nameLabel.text = fund.fundName;
    self.codeLabel.text = fund.fundCode;

    // 获取该分组的收益
    NSNumber *profit = fund.holdProfitByGroup[groupId];
    NSString *profitRate = fund.holdProfitRateByGroup[groupId];

    if (profit) {
        double profitValue = [profit doubleValue];
        if (profitValue >= 0) {
            self.profitLabel.text = [NSString stringWithFormat:@"+¥%.2f", profitValue];
            self.profitLabel.textColor = [UIColor systemRedColor];
        } else {
            self.profitLabel.text = [NSString stringWithFormat:@"¥%.2f", profitValue];
            self.profitLabel.textColor = [UIColor systemGreenColor];
        }
    } else {
        self.profitLabel.text = @"--";
        self.profitLabel.textColor = [UIColor labelColor];
    }

    if (profitRate && profitRate.length > 0) {
        self.profitRateLabel.text = profitRate;
        if ([profitRate hasPrefix:@"-"]) {
            self.profitRateLabel.textColor = [UIColor systemGreenColor];
        } else {
            self.profitRateLabel.textColor = [UIColor systemRedColor];
        }
    } else {
        self.profitRateLabel.text = @"--";
        self.profitRateLabel.textColor = [UIColor secondaryLabelColor];
    }
    
    // 获取该分组的持有金额
    NSNumber *holdAmount = fund.holdAmountByGroup[groupId];
    if (holdAmount.doubleValue > 0) {
        self.holdAmountLabel.text = [NSString stringWithFormat:@"持有: ¥%.2f", holdAmount.doubleValue + profit.doubleValue];
    } else {
        self.holdAmountLabel.text = @"持有: --";
    }
}

- (void)deleteButtonClicked {
    if (self.deleteButtonTapped) {
        self.deleteButtonTapped();
    }
}

@end

#pragma mark - FMImportConfirmViewController

@interface FMImportConfirmViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) NSMutableArray<FMFund *> *sortedFundModels;  // 排序后的基金列表（可编辑）

@end

@implementation FMImportConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"确认导入";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 按收益率排序
    [self sortFundsByProfitRate];

    [self setupUI];
}

- (void)sortFundsByProfitRate {
    // 按收益率从高到低排序
    self.sortedFundModels = [[self.fundModels sortedArrayUsingComparator:^NSComparisonResult(FMFund *fund1, FMFund *fund2) {
        // 获取收益率字符串
        NSString *rate1 = fund1.holdProfitRateByGroup[self.groupId];
        NSString *rate2 = fund2.holdProfitRateByGroup[self.groupId];

        // 解析收益率数值（去除 % 符号）
        double value1 = 0.0;
        double value2 = 0.0;

        if (rate1 && rate1.length > 0) {
            NSString *cleanRate1 = [rate1 stringByReplacingOccurrencesOfString:@"%" withString:@""];
            value1 = [cleanRate1 doubleValue];
        }

        if (rate2 && rate2.length > 0) {
            NSString *cleanRate2 = [rate2 stringByReplacingOccurrencesOfString:@"%" withString:@""];
            value2 = [cleanRate2 doubleValue];
        }

        // 从高到低排序
        if (value1 > value2) {
            return NSOrderedAscending;
        } else if (value1 < value2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }] mutableCopy];
}

- (void)setupUI {
    // 提示标签
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.text = [NSString stringWithFormat:@"识别到 %lu 个基金", (unsigned long)self.fundModels.count];
    self.tipLabel.font = [UIFont systemFontOfSize:14];
    self.tipLabel.textColor = [UIColor secondaryLabelColor];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tipLabel];

    // 表格视图
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[FMImportConfirmTableViewCell class] forCellReuseIdentifier:@"FundCell"];
    [self.view addSubview:self.tableView];

    // 确认按钮
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.confirmButton setTitle:@"新增到持有" forState:UIControlStateNormal];
    self.confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [UIColor systemBlueColor];
    self.confirmButton.layer.cornerRadius = 10;
    [self.confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.confirmButton];

    // 布局
    [NSLayoutConstraint activateConstraints:@[
        // 提示标签
        [self.tipLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16],
        [self.tipLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.tipLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],

        // 表格视图
        [self.tableView.topAnchor constraintEqualToAnchor:self.tipLabel.bottomAnchor constant:12],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.confirmButton.topAnchor constant:-16],

        // 确认按钮
        [self.confirmButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.confirmButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.confirmButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.confirmButton.heightAnchor constraintEqualToConstant:50],
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sortedFundModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMImportConfirmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FundCell" forIndexPath:indexPath];
    FMFund *fund = self.sortedFundModels[indexPath.row];
    [cell configurWithFund:fund groupId:self.groupId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    // 设置删除按钮回调
    __weak typeof(self) weakSelf = self;
    cell.deleteButtonTapped = ^{
        [weakSelf deleteFundAtIndex:indexPath.row];
    };

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (void)deleteFundAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.sortedFundModels.count) {
        return;
    }

    // 从数组中移除基金
    [self.sortedFundModels removeObjectAtIndex:index];

    // 更新 tipLabel 显示
    self.tipLabel.text = [NSString stringWithFormat:@"识别到 %lu 个基金", (unsigned long)self.sortedFundModels.count];

    // 刷新表格
    [self.tableView reloadData];
}

- (void)confirmAction {
    // 保存所有基金到分组
    for (FMFund *fund in self.sortedFundModels) {
        [[FMDataManager sharedManager] addSelectedFund:fund toGroup:self.groupId];
//        NSLog(@"计算持仓:%@, 持仓净值=%@", fund.holdAmountByGroup[self.groupId], fund.holdNetValueByGroup[self.groupId]);
    }

    // 显示成功提示
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成功"
                                                                   message:[NSString stringWithFormat:@"已添加 %lu 个基金到持有", (unsigned long)self.sortedFundModels.count]
                                                            preferredStyle:UIAlertControllerStyleAlert];

    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 返回到根视图控制器
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
