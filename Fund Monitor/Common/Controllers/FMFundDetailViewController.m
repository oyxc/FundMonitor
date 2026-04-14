//
//  FMFundDetailViewController.m
//  FundMonitor
//
//  基金详情页面 - 重构版本
//

#import "FMFundDetailViewController.h"
#import "FMNetworkManager.h"
#import "FMDataManager.h"
#import "FMFundDetailHeaderView.h"
#import "FMFundChartView.h"
#import "FMHistoryDataTableView.h"
#import "FMFundHistoryData.h"
#import "FMNetWorthTrendData.h"
#import "FMGroupSelectionView.h"
#import "FMGrandTotalData.h"
#import "FMPerformanceView.h"
#import "FMHistoryDataListViewController.h"
#import "FMFundDetailModel.h"
#import "FMEditHoldingViewController.h"
#import "FMTopHoldingsView.h"

typedef NS_ENUM(NSInteger, FMDetailTabType) {
    FMDetailTabTypeEstimate = 0,    // 净值估算
    FMDetailTabTypePerformance,     // 单位净值
    FMDetailTabTypeIncome           // 累计收益
};

@interface FMFundDetailViewController () <FMGroupSelectionViewDelegate>

// 头部信息视图
@property (nonatomic, strong) FMFundDetailHeaderView *headerView;

// 标签页控件
@property (nonatomic, strong) UISegmentedControl *segmentControl;

// 主滚动视图和内容容器
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) FMPerformanceView *performanceView; // 单位净值
@property (nonatomic, strong) FMTopHoldingsView *holdingsView; // 十大重仓

// 公共信息标签
@property (nonatomic, strong) UIView *infoLabelsContainer;  // 信息标签容器
@property (nonatomic, strong) UILabel *publicDateLabel;      // 日期
@property (nonatomic, strong) UILabel *publicNetWorthLabel;  // 单位净值
@property (nonatomic, strong) UILabel *publicDayRateLabel;   // 日涨幅

// 图表和时间段选择
@property (nonatomic, strong) FMFundChartView *chartView;
@property (nonatomic, strong) UISegmentedControl *periodSegmentControl;  // 时间段选择
@property (nonatomic, assign) NSInteger currentPeriodPageSize;  // 当前时间段对应的数据量

@property (nonatomic, strong) FMFundDetailModel *detailModel;

@end

@implementation FMFundDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"基金详情";
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];

    [self setupNavigationBar];
    [self setupUI];
    [self loadFundDetail];

    // 监听主题变更
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appearanceSettingDidChange)
                                                 name:@"AppearanceSettingDidChange"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup UI

- (void)setupNavigationBar {
    // 添加到其他分组按钮
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                         target:self
                                                                         action:@selector(editAction)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self
                                                                         action:@selector(addToGroupAction)];
    self.navigationItem.rightBarButtonItems = @[edit,add];
}

- (void)setupUI {
    CGFloat width = self.view.bounds.size.width;

    // 创建主滚动视图
    self.mainScrollView = [[UIScrollView alloc] init];
    self.mainScrollView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.mainScrollView];

    // 创建内容容器视图
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainScrollView addSubview:self.contentView];

    // 头部信息视图
    self.headerView = [[FMFundDetailHeaderView alloc] init];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.headerView];

    // 标签页控件
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"净值估算", @"单位净值", @"累计收益"]];
    self.segmentControl.selectedSegmentIndex = 0;
    [self.segmentControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.segmentControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.segmentControl];

    // 公共信息标签容器
    self.infoLabelsContainer = [[UIView alloc] init];
    self.infoLabelsContainer.backgroundColor = [UIColor systemBackgroundColor];
    self.infoLabelsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.infoLabelsContainer];

    // 日期标签
    self.publicDateLabel = [[UILabel alloc] init];
    self.publicDateLabel.font = [UIFont systemFontOfSize:14];
    self.publicDateLabel.textColor = [UIColor secondaryLabelColor];
    self.publicDateLabel.textAlignment = NSTextAlignmentCenter;
    self.publicDateLabel.text = @"--";
    self.publicDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoLabelsContainer addSubview:self.publicDateLabel];

    // 单位净值标签
    self.publicNetWorthLabel = [[UILabel alloc] init];
    self.publicNetWorthLabel.font = [UIFont systemFontOfSize:14];
    self.publicNetWorthLabel.textColor = [UIColor labelColor];
    self.publicNetWorthLabel.textAlignment = NSTextAlignmentCenter;
    self.publicNetWorthLabel.text = @"--";
    self.publicNetWorthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoLabelsContainer addSubview:self.publicNetWorthLabel];

    // 日涨幅标签
    self.publicDayRateLabel = [[UILabel alloc] init];
    self.publicDayRateLabel.font = [UIFont systemFontOfSize:14];
    self.publicDayRateLabel.textColor = [UIColor secondaryLabelColor];
    self.publicDayRateLabel.textAlignment = NSTextAlignmentCenter;
    self.publicDayRateLabel.text = @"--";
    self.publicDayRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoLabelsContainer addSubview:self.publicDayRateLabel];

    // 共享的图表视图（所有标签页都可见）
    self.chartView = [[FMFundChartView alloc] initWithFrame:CGRectMake(0, 0, width, 250)];
    self.chartView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.chartView];

    __weak typeof(self) weakSelf = self;
    self.chartView.selectBlock = ^(id  _Nonnull object) {
        //更新标签
        [weakSelf updateInfoLabelsWithModel:object];
    };

    // 共享的时间段选择控件（所有标签页都可见）
    self.periodSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"近1月", @"近3月", @"近6月", @"近1年", @"近3年"]];
    self.periodSegmentControl.selectedSegmentIndex = 2;  // 默认选中"近6月"
    self.periodSegmentControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.periodSegmentControl addTarget:self action:@selector(periodChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.periodSegmentControl];
    
    // 初始化默认时间段（近1月 = 30天）
    self.currentPeriodPageSize = 180;
    
    // 单位净值标签页
    self.performanceView = [[FMPerformanceView alloc] initWithFrame:CGRectMake(0, 0, width, 330)];
    self.performanceView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.performanceView];
    self.performanceView.showMoreButtonTappedBlock = ^{
        [weakSelf showFullHistoryDataList];
    };

    // 十大重仓视图
    self.holdingsView = [[FMTopHoldingsView alloc] init];
    self.holdingsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.holdingsView];

    // 布局约束
    [NSLayoutConstraint activateConstraints:@[
        // 主滚动视图填满整个视图
        [self.mainScrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.mainScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mainScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mainScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        // 内容容器视图
        [self.contentView.topAnchor constraintEqualToAnchor:self.mainScrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.mainScrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.mainScrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.mainScrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.mainScrollView.widthAnchor],

        // 头部信息视图
        [self.headerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],

        // 标签页控件
        [self.segmentControl.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:15],
        [self.segmentControl.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
        [self.segmentControl.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
        [self.segmentControl.heightAnchor constraintEqualToConstant:32],

        // 公共信息标签容器
        [self.infoLabelsContainer.topAnchor constraintEqualToAnchor:self.segmentControl.bottomAnchor constant:10],
        [self.infoLabelsContainer.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
        [self.infoLabelsContainer.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
        [self.infoLabelsContainer.heightAnchor constraintEqualToConstant:40],

        // 日期标签（左侧）
        [self.publicDateLabel.leadingAnchor constraintEqualToAnchor:self.infoLabelsContainer.leadingAnchor],
        [self.publicDateLabel.centerYAnchor constraintEqualToAnchor:self.infoLabelsContainer.centerYAnchor],
        [self.publicDateLabel.widthAnchor constraintEqualToAnchor:self.infoLabelsContainer.widthAnchor multiplier:0.33],

        // 单位净值标签（中间）
        [self.publicNetWorthLabel.centerXAnchor constraintEqualToAnchor:self.infoLabelsContainer.centerXAnchor],
        [self.publicNetWorthLabel.centerYAnchor constraintEqualToAnchor:self.infoLabelsContainer.centerYAnchor],
        [self.publicNetWorthLabel.widthAnchor constraintEqualToAnchor:self.infoLabelsContainer.widthAnchor multiplier:0.33],

        // 日涨幅标签（右侧）
        [self.publicDayRateLabel.trailingAnchor constraintEqualToAnchor:self.infoLabelsContainer.trailingAnchor],
        [self.publicDayRateLabel.centerYAnchor constraintEqualToAnchor:self.infoLabelsContainer.centerYAnchor],
        [self.publicDayRateLabel.widthAnchor constraintEqualToAnchor:self.infoLabelsContainer.widthAnchor multiplier:0.33],

        // 共享图表视图
        [self.chartView.topAnchor constraintEqualToAnchor:self.infoLabelsContainer.bottomAnchor constant:10],
        [self.chartView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.chartView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.chartView.heightAnchor constraintEqualToConstant:250],

        // 共享时间段选择控件
        [self.periodSegmentControl.topAnchor constraintEqualToAnchor:self.chartView.bottomAnchor constant:10],
        [self.periodSegmentControl.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
        [self.periodSegmentControl.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
        [self.periodSegmentControl.heightAnchor constraintEqualToConstant:32],
        
        // 单位净值标签页
        [self.performanceView.topAnchor constraintEqualToAnchor:self.periodSegmentControl.bottomAnchor constant:10],
        [self.performanceView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.performanceView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.performanceView.heightAnchor constraintEqualToConstant:330],

        // 十大重仓视图
        [self.holdingsView.topAnchor constraintEqualToAnchor:self.performanceView.bottomAnchor constant:10],
        [self.holdingsView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.holdingsView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.holdingsView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-20],
    ]];

    // 默认显示净值估算
    [self switchToTab:FMDetailTabTypeEstimate];
}

#pragma mark - Data Loading

- (void)loadFundDetail {
    if (!self.fund.fundCode) {
        return;
    }

    // 显示当前数据
    [self updateUI];
    
    // 加载十大重仓数据
    self.holdingsView.fundCode = self.fund.fundCode;
    [self.holdingsView loadHoldingsData];
    
    // 获取最新估值数据
    [[FMNetworkManager sharedManager] fetchFundDetail:self.fund.fundCode success:^(id responseObject) {
        if ([responseObject isKindOfClass:[FMFundDetailModel class]]) {
            FMFundDetailModel *updatedFund = responseObject;
            self.detailModel = updatedFund;
            [self updateUI];
        }
    } failure:^(NSError *error) {
        NSLog(@"加载基金详情失败: %@", error);
    }];
}

- (void)updateUI {
    // 更新头部信息
    self.headerView.fundName = self.detailModel.fundName;
    self.headerView.fundCode = self.detailModel.fundCode;
    self.headerView.fundType = self.fund.fundType;
    self.headerView.todayRate = self.fund.estimateRate;
    self.headerView.yearRate = self.detailModel.yearRate;
    [self.headerView updateDisplay];

    // 更新公共信息标签（显示最新数据）
    [self updateInfoLabelsWithModel:nil];

    // 更新单位净值标签页的表格数据
    if (self.detailModel.netWorthTrendData && self.detailModel.netWorthTrendData.count > 0) {
        [self.performanceView updateWithHistoryData:self.detailModel.netWorthTrendData];
    }

    // 更新当前标签页的图表
    [self switchToTab:self.segmentControl.selectedSegmentIndex];
}

- (void)updateLabelColorWithValue:(CGFloat)value label:(UILabel *)label
{
    // 根据涨跌设置颜色
    if (value > 0) {
        label.textColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];
    } else if (value < 0) {
        label.textColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0];
    } else {
        label.textColor = [UIColor secondaryLabelColor];
    }
}

// 更新公共信息标签
- (void)updateInfoLabelsWithModel:(id)object
{
    if (object == nil) {
        // 根据当前选中的标签页更新对应的图表和数据
        FMDetailTabType currentTab = (FMDetailTabType)self.segmentControl.selectedSegmentIndex;
        if (currentTab == FMDetailTabTypeEstimate) {
            // 净值估算标签页
            // 获取最新的数据点
            object = self.detailModel.netWorthTrendData.lastObject;

        } else if (currentTab == FMDetailTabTypeIncome) {
            // 累计收益标签页
            //多个走势图
            NSMutableArray *result = [NSMutableArray array];
            for (FMGrandTotalData *totalModel in self.detailModel.grandTotalData) {
                if (totalModel.data.count > 0) {
                    [result addObject:totalModel.data.lastObject];
                }
            }
            object = result;

        } else {
            // 单位净值标签页
            // 获取最新的数据点
            object = self.detailModel.netWorthTrendData.lastObject;
        }
    }
    
    if ([object isMemberOfClass:FMNetWorthTrendData.class]) {
        FMNetWorthTrendData *latestData = (FMNetWorthTrendData *)object;
        // 更新日期
        self.publicDateLabel.text = [latestData dateString];
        self.publicDateLabel.textColor = [UIColor secondaryLabelColor];
        // 更新单位净值
        self.publicNetWorthLabel.text = [NSString stringWithFormat:@"单位净值:%.4f", [latestData.netWorth doubleValue]];
        // 更新日涨幅
        double dayRate = [latestData.equityReturn doubleValue];// dayRate
        NSString *rateText = [NSString stringWithFormat:@"日涨幅:%.2f%%", dayRate];
        self.publicDayRateLabel.text = rateText;

        // 根据涨跌设置颜色
        [self updateLabelColorWithValue:dayRate label:self.publicDayRateLabel];
        [self updateLabelColorWithValue:dayRate label:self.publicNetWorthLabel];
    }
    //
    else if ([object isKindOfClass:NSArray.class]) {
        NSArray *source = (NSArray *)object;
        NSNumber *local, *same, *hs300;

        if (source.count > 0) {
            FMGrandTotalDataItem *first = source.firstObject;
            local = first.totalReturn;
        }
        if (source.count > 1) {
            FMGrandTotalDataItem *first = source[1];
            same = first.totalReturn;
        }
        if (source.count > 2) {
            FMGrandTotalDataItem *first = source.lastObject;
            hs300 = first.totalReturn;
        }
        
        // 更新日期
        self.publicDateLabel.text = [NSString stringWithFormat:@"本基金:%.2f",local.doubleValue];
        // 更新单位净值
        self.publicNetWorthLabel.text = [NSString stringWithFormat:@"同类平均:%.2f", same.doubleValue];
        // 更新日涨幅
        self.publicDayRateLabel.text = [NSString stringWithFormat:@"沪深300:%.2f", hs300.doubleValue];
        
        // 根据涨跌设置颜色
        [self updateLabelColorWithValue:local.doubleValue label:self.publicDateLabel];
        [self updateLabelColorWithValue:same.doubleValue label:self.publicNetWorthLabel];
        [self updateLabelColorWithValue:hs300.doubleValue label:self.publicDayRateLabel];
    }
    // 如果都没有数据，显示默认值
    else {
        self.publicDateLabel.text = @"--";
        self.publicNetWorthLabel.text = @"--";
        self.publicDayRateLabel.text = @"--";
        self.publicDateLabel.textColor = [UIColor secondaryLabelColor];
        self.publicNetWorthLabel.textColor = [UIColor labelColor];
        self.publicDayRateLabel.textColor = [UIColor secondaryLabelColor];
    }
}

#pragma mark - Actions

- (void)periodChanged:(UISegmentedControl *)segment {
    // 根据选中的时间段确定数据量
    NSInteger pageSize = 30;  // 默认近1月
    switch (segment.selectedSegmentIndex) {
        case 0:  // 近1月
            pageSize = 30;
            break;
        case 1:  // 近3月
            pageSize = 90;
            break;
        case 2:  // 近6月
            pageSize = 180;
            break;
        case 3:  // 近1年
            pageSize = 365;
            break;
        case 4:  // 近3年
            pageSize = 1095;
            break;
    }

    self.currentPeriodPageSize = pageSize;

    // 根据当前选中的标签页更新对应的图表和数据
    [self switchToTab:self.segmentControl.selectedSegmentIndex];
}

- (void)segmentChanged:(UISegmentedControl *)segment {
    [self switchToTab:segment.selectedSegmentIndex];
}

- (void)switchToTab:(FMDetailTabType)tabType {

    switch (tabType) {
        case FMDetailTabTypeEstimate:
            // 净值估算：显示净值走势数据
            [self updateChartForPerformance];
            break;
        case FMDetailTabTypePerformance:
            // 单位净值：显示单位净值走势数据
            [self updateChartForPerformance];
            break;
        case FMDetailTabTypeIncome:
            // 累计收益：显示累计收益数据
            [self updateChartForIncome];
            break;
    }

    //更新标签
    [self updateInfoLabelsWithModel:nil];
}

// MARK: 更新图表 - 单位净值
- (void)updateChartForPerformance {
    if (self.detailModel.netWorthTrendData && self.detailModel.netWorthTrendData.count > 0) {
        // 根据时间段选择显示数据
        NSArray *netData = self.detailModel.netWorthTrendData;
        NSInteger count = self.detailModel.netWorthTrendData.count;
        if (self.currentPeriodPageSize <= count) {
            netData = [self.detailModel.netWorthTrendData subarrayWithRange:NSMakeRange(count - self.currentPeriodPageSize, self.currentPeriodPageSize)];
        }
        self.chartView.netWorthTrendData = netData;
        [self.chartView updateChartWithNetWorthTrendData];
    }
}

// MARK: 更新图表 - 累计收益标签页
- (void)updateChartForIncome {
    if (self.detailModel.grandTotalData && self.detailModel.grandTotalData.count > 0) {
        // 使用 grandTotalData 显示累计收益图表
        self.chartView.grandTotalData = self.detailModel.grandTotalData;
        [self.chartView updateChartWithGrandTotalDataByCount:self.currentPeriodPageSize];
    }
}

- (void)editAction {
    FMEditHoldingViewController *editVC = [[FMEditHoldingViewController alloc] init];
    editVC.fund = self.fund;
    editVC.groupId = self.groupId;  // 传递当前分组ID
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)addToGroupAction {
    [self showGroupSelectionWithSelectedIds:nil];
}

- (void)showGroupSelectionWithSelectedIds:(NSSet<NSString *> *)selectedIds {
    NSArray<FMGroup *> *groups = [[FMDataManager sharedManager] getAllGroups];

    // 创建并显示底部弹窗
    FMGroupSelectionView *selectionView = [[FMGroupSelectionView alloc] initWithGroups:groups fund:self.fund selectedGroupIds:selectedIds];
    selectionView.delegate = self;
    [selectionView show];
}

- (void)showFullHistoryDataList {
    // 创建历史数据列表页面
    FMHistoryDataListViewController *listVC = [[FMHistoryDataListViewController alloc] init];
    listVC.historyData = self.detailModel.netWorthTrendData;
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
}

#pragma mark - FMGroupSelectionViewDelegate

- (void)groupSelectionFinishWithMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
