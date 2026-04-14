//
//  FMAddFundViewController.m
//  FundMonitor
//

#import "FMAddFundViewController.h"
#import "FMGroupSelectionView.h"
#import "FMNetworkManager.h"
#import "FMDataManager.h"
#import "FMFundCell.h"

@interface FMAddFundViewController () <FMGroupSelectionViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<FMFund *> *searchResults;
@property (nonatomic, strong) NSMutableArray<FMFund *> *allSearchResults; // 所有搜索结果
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL hasMoreData;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation FMAddFundViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"添加基金";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupNavigationBar];
    [self setupUI];

    // 监听主题变更
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appearanceSettingDidChange)
                                                 name:@"AppearanceSettingDidChange"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigationBar {
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)setupUI {
    // 搜索框
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"输入基金代码或名称";
    self.searchBar.delegate = self;
    //self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.searchBar];

    // 表格
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.rowHeight = 44;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 80;
    [self.view addSubview:self.tableView];

    // 空状态提示
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"请输入基金代码或名称进行搜索";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [UIColor grayColor];
    self.emptyLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.emptyLabel];

    // 布局
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.searchBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.emptyLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [self.emptyLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40]
    ]];

    self.searchResults = [NSMutableArray array];
    self.allSearchResults = [NSMutableArray array];
    self.currentPage = 0;
    self.pageSize = 20; // 每页显示20条
    self.hasMoreData = NO;
    self.isLoading = NO;

    // 加载指示器
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingView.hidesWhenStopped = YES;

    [self updateEmptyState];
}

- (void)updateEmptyState {
    if (self.searchResults.count == 0) {
        self.emptyLabel.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.emptyLabel.hidden = YES;
        self.tableView.hidden = NO;
    }
}

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];

    NSString *keyword = searchBar.text;
    if (keyword.length == 0) {
        return;
    }

    // 重置分页状态
    self.currentPage = 0;
    [self.searchResults removeAllObjects];
    [self.allSearchResults removeAllObjects];

    // 开始搜索
    [self searchFundsWithKeyword:keyword];
}

- (void)searchFundsWithKeyword:(NSString *)keyword {
    if (self.isLoading) {
        return;
    }

    self.isLoading = YES;
    [self.loadingView startAnimating];

    // 搜索基金
    [[FMNetworkManager sharedManager] searchFundWithKeyword:keyword success:^(id responseObject) {
        self.isLoading = NO;
        [self.loadingView stopAnimating];

        if ([responseObject isKindOfClass:[NSArray class]]) {
            // 保存所有搜索结果
            self.allSearchResults = [responseObject mutableCopy];

            // 标记已加入自选的基金
            for (FMFund *fund in self.allSearchResults) {
                fund.isSelected = [[FMDataManager sharedManager] isFundSelected:fund.fundCode];
            }

            // 加载第一页数据
            [self loadMoreData];

            [self updateEmptyState];

            if (self.allSearchResults.count == 0) {
                self.emptyLabel.text = @"未找到相关基金";
            }
        }
    } failure:^(NSError *error) {
        self.isLoading = NO;
        [self.loadingView stopAnimating];

        NSLog(@"搜索失败: %@", error);

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"搜索失败，请稍后重试"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)loadMoreData {
    if (self.isLoading || (!self.hasMoreData && self.currentPage > 0)) {
        return;
    }

    NSInteger startIndex = self.currentPage * self.pageSize;
    NSInteger endIndex = MIN(startIndex + self.pageSize, self.allSearchResults.count);

    if (startIndex >= self.allSearchResults.count) {
        self.hasMoreData = NO;
        return;
    }

    // 获取当前页的数据
    NSArray *pageData = [self.allSearchResults subarrayWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
    [self.searchResults addObjectsFromArray:pageData];

    // 更新分页状态
    self.currentPage++;
    self.hasMoreData = (endIndex < self.allSearchResults.count);

    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 如果有更多数据，多显示一行用于"加载更多"
    return self.searchResults.count + (self.hasMoreData ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 判断是否是"加载更多"行
    if (indexPath.row == self.searchResults.count && self.hasMoreData) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadMoreCell"];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor systemBlueColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        if (self.isLoading) {
            cell.textLabel.text = @"加载中...";

            // 添加加载指示器
            if (!self.loadingView.superview) {
                self.loadingView.frame = CGRectMake(0, 0, 20, 20);
                cell.accessoryView = self.loadingView;
                [self.loadingView startAnimating];
            }
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"加载更多 (还有 %ld 条)", (long)(self.allSearchResults.count - self.searchResults.count)];
            cell.accessoryView = nil;
        }

        return cell;
    }

    // 正常的基金Cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FMFundCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FMFundCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    FMFund *fundItem = self.searchResults[indexPath.row];
    cell.textLabel.text = fundItem.fundName;
    cell.detailTextLabel.text = fundItem.fundCode;

    // 添加附加标识
    if (fundItem.isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 判断是否点击了"加载更多"行
    if (indexPath.row == self.searchResults.count && self.hasMoreData) {
        [self loadMoreData];
        return;
    }

    // 正常的基金选择逻辑
    if (indexPath.row >= self.searchResults.count) {
        return;
    }

    FMFund *fund = self.searchResults[indexPath.row];

    if (fund.isSelected) {
        // 已加入自选
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"该基金已在自选列表中"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // 选择分组
        [self showGroupSelectionWithSelectedIds:nil fund:fund];
    }
}

- (void)showGroupSelectionWithSelectedIds:(NSSet<NSString *> *)selectedIds fund:(FMFund *)fund {
    NSArray<FMGroup *> *groups = [[FMDataManager sharedManager] getAllGroups];
    
    // 创建并显示底部弹窗
    FMGroupSelectionView *selectionView = [[FMGroupSelectionView alloc] initWithGroups:groups fund:fund selectedGroupIds:selectedIds];
    selectionView.delegate = self;
    [selectionView show];
}

#pragma mark - FMGroupSelectionViewDelegate

- (void)groupSelectionFinishWithMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    [self.tableView reloadData];
}

@end
