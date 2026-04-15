//
//  FMHotFundsViewController.m
//  FundMonitor
//

#import "FMHotFundsViewController.h"
#import "FMHotFundCell.h"
#import "FMHotFundModel.h"
#import "FMHotFundHeaderView.h"
#import "FMNetworkManager.h"
#import "FMFundDetailViewController.h"
#import "FMFund.h"

@interface FMHotFundsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) FMHotFundHeaderView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<FMHotFundModel *> *hotFunds;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (nonatomic, strong) NSArray<NSString *> *fundTypes;  // 基金类型代码数组
@property (nonatomic, assign) NSInteger currentPageIndex;      // 当前页码

@end

@implementation FMHotFundsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"热门";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // 初始化基金类型数组
    self.fundTypes = @[@"", @"gp", @"zq", @"zs", @"hh", @"qdii"];
    self.currentPageIndex = 1;

    [self setupUI];
    [self loadHotFunds];

    // 监听主题变更
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appearanceSettingDidChange)
                                                 name:@"AppearanceSettingDidChange"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    // UISegmentedControl
    NSArray *titles = @[@"月销量", @"股票型", @"债券型", @"指数型", @"混合型", @"QDII"];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:titles];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.segmentedControl];

    // 筛选头部视图
    self.headerView = [[FMHotFundHeaderView alloc] init];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    __weak typeof(self) weakSelf = self;
    self.headerView.onFilterChanged = ^(FMHotFundFilterType type) {
        [weakSelf sortData];
    };
    [self.view addSubview:self.headerView];

    // 表格
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 65;
    [self.tableView registerClass:[FMHotFundCell class] forCellReuseIdentifier:@"FMHotFundCell"];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    // 下拉刷新
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;

    // 加载指示器
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingView.center = self.view.center;
    [self.view addSubview:self.loadingView];

    // 布局
    [NSLayoutConstraint activateConstraints:@[
        // SegmentedControl
        [self.segmentedControl.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [self.segmentedControl.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.segmentedControl.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],

        // HeaderView
        [self.headerView.topAnchor constraintEqualToAnchor:self.segmentedControl.bottomAnchor constant:8],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.headerView.heightAnchor constraintEqualToConstant:38],

        // TableView
        [self.tableView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)sortData {
    FMHotFundFilterType filterType = self.headerView.filterType;
    NSArray *funds = [self.hotFunds sortedArrayUsingComparator:^NSComparisonResult(FMHotFundModel *obj1, FMHotFundModel *obj2) {
        if (filterType == FMHotFundFilterTypeThisYear) {
            return obj1.rateThisYear.doubleValue < obj2.rateThisYear.doubleValue;
        }
        if (filterType == FMHotFundFilterType1Month) {
            return obj1.rate1Month.doubleValue < obj2.rate1Month.doubleValue;
        }
        if (filterType == FMHotFundFilterType6Month) {
            return obj1.rate6Month.doubleValue < obj2.rate6Month.doubleValue;
        }
        //默认
        return obj1.rate1Year.doubleValue < obj2.rate1Year.doubleValue;
    }];
    
    self.hotFunds = [funds mutableCopy];
    [self.tableView reloadData];
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    // 切换 Segment 时重新加载数据
    self.currentPageIndex = 1;
    [self loadHotFunds];
}

- (void)loadHotFunds {
    [self.loadingView startAnimating];

    // 获取当前选中的基金类型
    NSInteger selectedIndex = self.segmentedControl.selectedSegmentIndex;
    NSString *fundType = self.fundTypes[selectedIndex];

    // 请求数据
    [[FMNetworkManager sharedManager] fetchHotFundRanking:fundType
                                                companyId:self.companyId
                                                pageIndex:self.currentPageIndex
                                                 pageSize:50
                                                  success:^(id responseObject) {
        [self.loadingView stopAnimating];
        [self.refreshControl endRefreshing];

        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.hotFunds = [responseObject mutableCopy];
            [self sortData];
        }
    } failure:^(NSError *error) {
        [self.loadingView stopAnimating];
        [self.refreshControl endRefreshing];

        NSLog(@"加载热门基金失败: %@", error);

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"加载失败，请稍后重试"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)refreshData {
    self.currentPageIndex = 1;
    [self loadHotFunds];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hotFunds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMHotFundCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FMHotFundCell" forIndexPath:indexPath];
    cell.model = self.hotFunds[indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    FMHotFundModel *hotFund = self.hotFunds[indexPath.row];

    // 转换为 FMFund 对象
    FMFund *fund = [FMFund fundWithCode:hotFund.fundCode name:hotFund.fundName];
    fund.fundType = hotFund.fundType;
    fund.latestValue = hotFund.unitNetValue;
    fund.latestRate = hotFund.rate6Month;

    // 将整个热门基金列表转换为 FMFund 数组，用于侧滑切换
    NSMutableArray<FMFund *> *fundList = [NSMutableArray arrayWithCapacity:self.hotFunds.count];
    for (FMHotFundModel *model in self.hotFunds) {
        FMFund *f = [FMFund fundWithCode:model.fundCode name:model.fundName];
        f.fundType = model.fundType;
        f.latestValue = model.unitNetValue;
        f.latestRate = model.rate6Month;
        [fundList addObject:f];
    }

    FMFundDetailViewController *vc = [[FMFundDetailViewController alloc] init];
    vc.fund = fund;
    vc.fundList = [fundList copy];
    vc.currentIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    [self.tableView reloadData];
}

@end
