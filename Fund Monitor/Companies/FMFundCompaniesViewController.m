//
//  FMFundCompaniesViewController.m
//  FundMonitor
//
//  基金公司列表页面
//

#import "FMFundCompaniesViewController.h"
#import "FMHotFundsViewController.h"
#import "FMNetworkManager.h"
#import "FMFundCompany.h"

@interface FMFundCompaniesViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray<FMFundCompany *> *companies;
@property (nonatomic, strong) NSArray<FMFundCompany *> *filteredCompanies;
@property (nonatomic, assign) BOOL isSearching;

@end

@implementation FMFundCompaniesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"基金公司";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    [self loadCompanies];
}

- (void)setupUI {
    // 搜索栏
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.searchBar.placeholder = @"搜索基金公司";
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;

    // 表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60;
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CompanyCell"];
    [self.view addSubview:self.tableView];

    // 下拉刷新
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadCompanies) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
}

- (void)loadCompanies {
    [[FMNetworkManager sharedManager] fetchFundCompanies:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.companies = responseObject;
            self.filteredCompanies = self.companies;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"加载基金公司失败: %@", error);
        [self.refreshControl endRefreshing];

        // 显示错误提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加载失败"
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearching ? self.filteredCompanies.count : self.companies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompanyCell"];

    // 使用 UITableViewCellStyleValue1 样式来显示详细信息
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CompanyCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    FMFundCompany *company = self.isSearching ? self.filteredCompanies[indexPath.row] : self.companies[indexPath.row];

    cell.textLabel.text = company.companyName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"ID: %@", company.companyId];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    FMFundCompany *company = self.isSearching ? self.filteredCompanies[indexPath.row] : self.companies[indexPath.row];

    // TODO: 跳转到基金公司详情页面
    NSLog(@"选中基金公司: %@ (ID: %@)", company.companyName, company.companyId);
    
    FMHotFundsViewController *vc = [[FMHotFundsViewController alloc] init];
    vc.companyId = company.companyId;
    [self.navigationController pushViewController:vc animated:YES];

//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:company.companyName
//                                                                   message:[NSString stringWithFormat:@"公司ID: %@", company.companyId]
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
//    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.isSearching = NO;
        self.filteredCompanies = self.companies;
    } else {
        self.isSearching = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyName CONTAINS[cd] %@", searchText];
        self.filteredCompanies = [self.companies filteredArrayUsingPredicate:predicate];
    }

    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.isSearching = NO;
    self.filteredCompanies = self.companies;
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

@end
