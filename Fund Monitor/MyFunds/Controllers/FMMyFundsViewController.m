//
//  FMMyFundsViewController.m
//  FundMonitor
//

#import "FMMyFundsViewController.h"
#import "FMFundCell.h"
#import "FMDataManager.h"
#import "FMNetworkManager.h"
#import "FMFundDetailViewController.h"
#import "FMAddFundViewController.h"
#import "FMGroupManageViewController.h"
#import "FMImportFundViewController.h"
#import "FMAssetCardView.h"
#import "FMListHeaderView.h"
#import "FMSettingsManager.h"
#import "FMNetWorthModel.h"

@interface FMMyFundsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *groupSegment;
@property (nonatomic, strong) NSMutableArray<FMGroup *> *groups;
@property (nonatomic, strong) NSMutableArray<FMFund *> *funds;
@property (nonatomic, strong) FMGroup *currentGroup;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

// 新增视图组件
@property (nonatomic, strong) FMAssetCardView *assetCardView;
@property (nonatomic, strong) FMListHeaderView *listHeaderView;
@property (nonatomic, assign) NSInteger latestEstimateTime;

// 自动刷新定时器
@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation FMMyFundsViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopAutoRefresh];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"自选";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    [self setupNavigationBar];
    [self setupUI];
    [self loadData];

    // 监听刷新频率变更
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshIntervalDidChange)
                                                 name:@"RefreshIntervalDidChange"
                                               object:nil];

    // 监听主题变更
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appearanceSettingDidChange)
                                                 name:@"AppearanceSettingDidChange"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startAutoRefresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAutoRefresh];
}

- (void)setupNavigationBar {
    // 添加基金按钮
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addFundAction)];

    // 管理分组按钮
    UIBarButtonItem *manageItem = [[UIBarButtonItem alloc] initWithTitle:@"分组"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(manageGroupAction)];

    self.navigationItem.rightBarButtonItems = @[addItem, manageItem];
    
    // 刷新标识
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.indicatorView.color = UIColor.labelColor;
    
    UIBarButtonItem *freshItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
    self.navigationItem.leftBarButtonItems = @[freshItem];
}

- (void)setupUI {
    // 资产卡片
    self.assetCardView = [[FMAssetCardView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.assetCardView.onEyeButtonTapped = ^{
        [weakSelf updateAssetCard];
    };
    [self.view addSubview:self.assetCardView];

    // 分组选择器
    self.groupSegment = [[UISegmentedControl alloc] init];
    [self.groupSegment addTarget:self action:@selector(groupChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.groupSegment];

    // 列表头部
    self.listHeaderView = [[FMListHeaderView alloc] init];
    self.listHeaderView.onSortChanged = ^(FMSortType type) {
        [weakSelf sortFundsByType:type];
    };
    [self.view addSubview:self.listHeaderView];

    // 表格
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    [self.tableView registerClass:[FMFundCell class] forCellReuseIdentifier:@"FMFundCell"];
    [self.view addSubview:self.tableView];
    [self addTableFootView];

    // 下拉刷新
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;

    // 布局
    self.assetCardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.groupSegment.translatesAutoresizingMaskIntoConstraints = NO;
    self.listHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat kTabBarHeight = [[UITabBarController alloc] init].tabBar.frame.size.height;
    CGFloat kSafeAreaHeight = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
    CGFloat safeHeight = kTabBarHeight + kSafeAreaHeight;

    [NSLayoutConstraint activateConstraints:@[
        // 分组选择器（最上面）
        [self.groupSegment.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [self.groupSegment.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
        [self.groupSegment.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
        [self.groupSegment.heightAnchor constraintEqualToConstant:32],

        // 资产卡片
        [self.assetCardView.topAnchor constraintEqualToAnchor:self.groupSegment.bottomAnchor constant:2],
        [self.assetCardView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
        [self.assetCardView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
        [self.assetCardView.heightAnchor constraintEqualToConstant:65],

        // 列表头部
        [self.listHeaderView.topAnchor constraintEqualToAnchor:self.assetCardView.bottomAnchor constant:2],
        [self.listHeaderView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.listHeaderView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        // 表格
        [self.tableView.topAnchor constraintEqualToAnchor:self.listHeaderView.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-safeHeight]
    ]];
}

- (void)loadData {
    // 加载分组
    self.groups = [[[FMDataManager sharedManager] getAllGroups] mutableCopy];

    // 分组选择器
    if (self.groupSegment.numberOfSegments != self.groups.count) {
        [self.groupSegment removeAllSegments];
        for (NSInteger i = 0; i < self.groups.count; i++) {
            FMGroup *group = self.groups[i];
            [self.groupSegment insertSegmentWithTitle:group.groupName atIndex:i animated:NO];
        }
        self.groupSegment.selectedSegmentIndex = 0;
    }

    [self groupChanged:self.groupSegment];
}

- (void)loadFundsForCurrentGroup {
    if (!self.currentGroup) {
        self.funds = [NSMutableArray array];
        [self updateAssetCard];
        [self.tableView reloadData];
        return;
    }

    NSLog(@"读取本地数据");
    self.funds = [[[FMDataManager sharedManager] getFundsInGroup:self.currentGroup.groupId] mutableCopy];
    [self updateAssetCard];
    [self sortFundsByType:self.listHeaderView.sortType];
    NSLog(@"读取本地数据完毕，显示数据");

    // 刷新估值数据
    [self refreshEstimateValues];
}

- (void)refreshEstimateValues {
    if (self.funds.count == 0) {
        return;
    }

    NSMutableArray *codes = [NSMutableArray array];
    for (FMFund *fund in self.funds) {
        if (fund.valuationTrack.length) {
            [codes addObject:fund.valuationTrack];
        } else if (fund.fundCode.length) {
            [codes addObject:fund.fundCode];
        }
    }
    NSLog(@"开始读取");
    [self.indicatorView startAnimating];
    [[FMNetworkManager sharedManager] fetchMultipleFundsEstimate:codes success:^(id responseObject) {
        [self.indicatorView stopAnimating];
        NSLog(@"读取完毕");
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSArray<FMNetWorthModel *> *updatedFunds = responseObject;

            for (FMNetWorthModel *updatedFund in updatedFunds) {
                for (NSInteger i = 0; i < self.funds.count; i++) {
                    FMFund *fund = self.funds[i];
                    if (fund.valuationTrack.length && [fund.valuationTrack isEqualToString:updatedFund.fundCode]) {
                        // 仅更新估值涨跌幅
                        fund.estimateTime = updatedFund.estimateDate;                        
                        fund.estimateRate = updatedFund.estimateGrowthRate;
                        double value = fund.latestValue.doubleValue + fund.latestValue.doubleValue * fund.estimateRate.doubleValue / 100;
                        fund.estimateValue = @(value).stringValue;
                        [[FMDataManager sharedManager] updateFund:fund];
                        break;
                    }

                    if ([fund.fundCode isEqualToString:updatedFund.fundCode]) {
                        if (fund.valuationTrack.length == 0) {
                            // 更新估值数据
                            fund.estimateTime = updatedFund.estimateDate;
                            fund.estimateRate = updatedFund.estimateGrowthRate;
                            fund.estimateValue = updatedFund.estimateNetValue;
                        }
                        
                        // 设置昨日数据
                        if (updatedFund.netValueDate.length) {
                            fund.latestTime = updatedFund.netValueDate;
                        }
                        if (updatedFund.unitNetValue.length) {
                            fund.latestValue = updatedFund.unitNetValue;
                        }
                        if (updatedFund.growthRate.length) {
                            fund.latestRate = updatedFund.growthRate;
                        }

                        // 根据持仓净值和当前净值计算当前持仓收益
                        NSString *groupId = self.currentGroup.groupId;
                        if (groupId) {
                            NSNumber *holdAmount = [fund holdAmountForGroup:groupId];
                            NSNumber *holdNetValue = [fund holdNetValueForGroup:groupId];

                            if (holdAmount && [holdAmount doubleValue] > 0 && holdNetValue && [holdNetValue doubleValue] > 0) {
                                // 使用最新净值
                                double currentNetValue = [fund.latestValue doubleValue];
                                if (currentNetValue > 0) {
                                    double holdNetValueDouble = [holdNetValue doubleValue];
                                    double holdAmountDouble = [holdAmount doubleValue];

                                    // 实时收益率 = (当前净值 - 持仓净值) / 持仓净值 * 100
                                    double realTimeProfitRate = (currentNetValue - holdNetValueDouble) / holdNetValueDouble * 100;

                                    // 实时收益 = 持有金额 * 实时收益率 / 100
                                    double realTimeProfit = holdAmountDouble * realTimeProfitRate / 100;

                                    [fund setHoldProfit:@(realTimeProfit) forGroup:groupId];
                                    [fund setHoldProfitRate:[NSString stringWithFormat:@"%.2f%%", realTimeProfitRate] forGroup:groupId];

//                                    NSLog(@"基金 %@ 实时收益计算: 持仓净值=%.4f, 当前净值=%.4f, 收益率=%.2f%%, 收益=%.2f",
//                                          fund.fundCode, holdNetValueDouble, currentNetValue, realTimeProfitRate, realTimeProfit);
                                }
                            }
                        }

                        [[FMDataManager sharedManager] updateFund:fund];
                        break;
                    }
                }
            }
            
            [self updateAssetCard];
            [self sortFundsByType:self.listHeaderView.sortType];
        }
    } failure:^(NSError *error) {
        [self.indicatorView stopAnimating];
        NSLog(@"刷新估值失败: %@", error);
    }];
}

- (void)updateAssetCard {
    // 计算总资产和当日收益（使用当前分组的持仓数据）
    double totalAsset = 0;
    double todayProfit = 0;
    FMFund *latestTimeFund = self.funds.firstObject;
    FMFund *estimateTimeFund = self.funds.firstObject;

    NSString *groupId = self.currentGroup.groupId;
    for (FMFund *fund in self.funds) {
        // 使用分组特定的持仓数据
        NSNumber *holdAmount = [fund holdAmountForGroup:groupId];
        NSNumber *holdProfit = [fund holdProfitForGroup:groupId];
        CGFloat estimateRate = fund.estimateRate.doubleValue;

        if (holdAmount) {
            totalAsset += [holdAmount doubleValue];
        }
        if (holdProfit) {
            totalAsset += [holdProfit doubleValue];
        }
        todayProfit += estimateRate/100 * (holdAmount.doubleValue + holdProfit.doubleValue);
        
        //筛选净值时间最新的数据
        if (fund.latestTimeInt > latestTimeFund.latestTimeInt) {
            latestTimeFund = fund;
        }
        //筛选估值时间最新的数据
        if (fund.estimateTimeInt > estimateTimeFund.estimateTimeInt) {
            estimateTimeFund = fund;
        }
    }

    NSString *estimateTime = estimateTimeFund.estimateTime?:@"--";
    if (estimateTime.length > 5) {
        estimateTime = [estimateTime substringFromIndex:5];
    }
    
    self.latestEstimateTime = estimateTimeFund.estimateTimeInt;
    self.assetCardView.totalAsset = totalAsset;
    self.assetCardView.todayProfit = todayProfit;
    [self.assetCardView updateDateLabelWithTime:estimateTime];
    self.listHeaderView.fund = latestTimeFund;
    [self.listHeaderView updateEstimateTime:estimateTimeFund.estimateTime latestTime:latestTimeFund.latestTime];

    if (totalAsset > 0) {
        self.assetCardView.todayProfitRate = (todayProfit / totalAsset) * 100.0;
    } else {
        self.assetCardView.todayProfitRate = 0;
    }

    [self.assetCardView updateAssetData];
}

- (void)addTableFootView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [addButton setTitle:@"+新增持仓" forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [addButton addTarget:self action:@selector(addHoldingAction) forControlEvents:UIControlEventTouchUpInside];
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [footerView addSubview:addButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [addButton.topAnchor constraintEqualToAnchor:footerView.topAnchor constant:10],
        [addButton.leadingAnchor constraintEqualToAnchor:footerView.leadingAnchor constant:16],
        [addButton.heightAnchor constraintEqualToConstant:36],
    ]];
    
    self.tableView.tableFooterView = footerView;
}

- (void)addHoldingAction {
    [self showImportViewController];
}

- (void)showImportViewController {
    FMImportFundViewController *importVC = [[FMImportFundViewController alloc] init];
    importVC.groupId = self.currentGroup.groupId;
    [self.navigationController pushViewController:importVC animated:YES];
}

- (void)refreshData {
    [self loadData];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Actions

- (void)groupChanged:(UISegmentedControl *)segment {
    NSInteger index = segment.selectedSegmentIndex;
    if (index >= 0 && index < self.groups.count) {
        self.currentGroup = self.groups[index];
        [self loadFundsForCurrentGroup];
    }
}

- (void)addFundAction {
    FMAddFundViewController *vc = [[FMAddFundViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)manageGroupAction {
    FMGroupManageViewController *vc = [[FMGroupManageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sortFundsByType:(FMSortType)type {
    BOOL ascending = self.listHeaderView.ascending;
    NSString *groupId = self.currentGroup.groupId;
    
    switch (type) {
        case FMSortTypeEstimate:
            [self.funds sortUsingComparator:^NSComparisonResult(FMFund *fund1, FMFund *fund2) {
                double rate1 = fund1.estimateRate ? [fund1.estimateRate doubleValue] : 0;
                double rate2 = fund2.estimateRate ? [fund2.estimateRate doubleValue] : 0;
                if (ascending) {
                    return rate1 > rate2 ? NSOrderedDescending : NSOrderedAscending;
                } else {
                    return rate1 < rate2 ? NSOrderedDescending : NSOrderedAscending;
                }
            }];
            break;

        case FMSortTypeLatest:
            [self.funds sortUsingComparator:^NSComparisonResult(FMFund *fund1, FMFund *fund2) {
                double rate1 = fund1.latestRate ? [fund1.latestRate doubleValue] : 0;
                double rate2 = fund2.latestRate ? [fund2.latestRate doubleValue] : 0;
                if (ascending) {
                    return rate1 > rate2 ? NSOrderedDescending : NSOrderedAscending;
                } else {
                    return rate1 < rate2 ? NSOrderedDescending : NSOrderedAscending;
                }
            }];
            break;

        case FMSortTypeProfit:{
            [self.funds sortUsingComparator:^NSComparisonResult(FMFund *fund1, FMFund *fund2) {
                double profit1 = [[fund1 holdProfitRateForGroup:groupId] doubleValue];
                double profit2 = [[fund2 holdProfitRateForGroup:groupId] doubleValue];
                if (ascending) {
                    return profit1 > profit2 ? NSOrderedDescending : NSOrderedAscending;
                } else {
                    return profit1 < profit2 ? NSOrderedDescending : NSOrderedAscending;
                }
            }];
        }   break;

        case FMSortTypeNone:
        default:
            // 默认按添加时间排序
            [self.funds sortUsingComparator:^NSComparisonResult(FMFund *fund1, FMFund *fund2) {
                return [fund1.addTime compare:fund2.addTime];
            }];
            break;
    }

    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.funds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMFundCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FMFundCell" forIndexPath:indexPath];
    cell.noLabel.text = @(indexPath.row).stringValue;
    cell.groupId = self.currentGroup.groupId;  // 传递当前分组ID
    [cell setFund:self.funds[indexPath.row] estimateTimeInt:self.latestEstimateTime latestTimeInt:self.listHeaderView.fund.latestTimeInt];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FMFund *fund = self.funds[indexPath.row];

    FMFundDetailViewController *vc = [[FMFundDetailViewController alloc] init];
    vc.fund = fund;
    vc.groupId = self.currentGroup.groupId;  // 传递当前分组ID
    vc.fundList = [self.funds copy];
    vc.currentIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 删除操作
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:@"删除"
                                                                             handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        // 显示确认对话框
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                       message:@"确定要从持仓中删除该基金吗？"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(NO);
        }];

        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            FMFund *fund = self.funds[indexPath.row];
            [[FMDataManager sharedManager] removeFund:fund.fundCode fromGroup:self.currentGroup.groupId];
            [self.funds removeObjectAtIndex:indexPath.row];
            [self updateAssetCard];
            [tableView reloadData];
            completionHandler(YES);
        }];

        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    // 禁止滑动自动触发删除，必须点击删除按钮
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}

#pragma mark - Auto Refresh

// 判断当前是否在交易时间段内
- (BOOL)isInTradingTime {
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
//    NSInteger hour = components.hour;
//    NSInteger minute = components.minute;
//    
//    // 9:30 - 11:30
//    if ((hour == 9 && minute >= 30) || (hour == 10) || (hour == 11 && minute <= 30)) {
//        return YES;
//    }
//    
//    // 13:00 - 15:00
//    if ((hour == 13) || (hour == 14) || (hour == 15 && minute == 0)) {
//        return YES;
//    }
    
    return NO;
}

- (void)startAutoRefresh {
    [self stopAutoRefresh];

    NSInteger interval = [FMSettingsManager sharedManager].refreshInterval;
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                         target:self
                                                       selector:@selector(autoRefreshData)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)stopAutoRefresh {
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)autoRefreshData {
    //交易时间段内自动刷新
    if ([self isInTradingTime]) {
        // 调用现有的刷新方法
        [self refreshEstimateValues];
    }
}

- (void)refreshIntervalDidChange {
    // 重启定时器以应用新的刷新频率
    [self startAutoRefresh];
}

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    [self.tableView reloadData];
}

@end
