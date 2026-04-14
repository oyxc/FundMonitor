//
//  FMHistoryDataListViewController.m
//  Fund Monitor
//
//  历史数据列表页面 - 显示全部历史净值数据
//

#import "FMHistoryDataListViewController.h"
#import "FMHistoryDataTableView.h"
#import "FMNetWorthTrendData.h"

@interface FMHistoryDataListViewController ()

@property (nonatomic, strong) FMHistoryDataTableView *tableView;

@end

@implementation FMHistoryDataListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"历史净值";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    [self loadData];
}

- (void)setupUI {
    // 创建表格视图
    self.tableView = [[FMHistoryDataTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

- (void)loadData {
    if (self.historyData) {
        self.tableView.historyData = self.historyData.reverseObjectEnumerator.allObjects;;
        [self.tableView reloadData];
    }
}

@end
