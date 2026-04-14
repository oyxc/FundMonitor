//
//  FMRefreshIntervalViewController.m
//  FundMonitor
//
//  刷新频率选择页面实现
//

#import "FMRefreshIntervalViewController.h"
#import "FMSettingsManager.h"

@interface FMRefreshIntervalViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSNumber *> *intervals;

@end

@implementation FMRefreshIntervalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"刷新频率";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.intervals = @[@3, @5, @7];

    [self setupUI];
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.intervals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSInteger interval = [self.intervals[indexPath.row] integerValue];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld秒", (long)interval];

    // 显示选中状态
    NSInteger currentInterval = [FMSettingsManager sharedManager].refreshInterval;
    if (interval == currentInterval) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger interval = [self.intervals[indexPath.row] integerValue];
    [FMSettingsManager sharedManager].refreshInterval = interval;
    [[FMSettingsManager sharedManager] saveSettings];

    // 刷新表格显示
    [self.tableView reloadData];

    // 发送通知，让自选页面更新定时器
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshIntervalDidChange" object:nil];

    // 延迟返回，让用户看到选中效果
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"设置自选基金页面的自动刷新频率";
}

@end
