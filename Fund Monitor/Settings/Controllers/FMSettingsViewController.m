//
//  FMSettingsViewController.m
//  FundMonitor
//
//  设置主页面实现
//

#import "FMSettingsViewController.h"
#import "FMSettingsManager.h"
#import "FMAboutViewController.h"
#import "FMRefreshIntervalViewController.h"

@interface FMSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"设置";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 刷新显示，以更新刷新频率的值
    [self.tableView reloadData];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // 清除之前的 accessoryView
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = nil;

    // 使用 UITableViewCellStyleValue1 样式来显示详细信息
    if (cell.detailTextLabel == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }

    if (indexPath.row == 0) {
        // 关于
        cell.textLabel.text = @"关于";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if (indexPath.row == 1) {
        // 肤色跟随系统
        cell.textLabel.text = @"肤色跟随系统";
        UISwitch *switchView = [[UISwitch alloc] init];
        switchView.on = [FMSettingsManager sharedManager].followSystemAppearance;
        [switchView addTarget:self action:@selector(appearanceSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.row == 2) {
        // 刷新频率
        cell.textLabel.text = @"刷新频率";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lds", (long)[FMSettingsManager sharedManager].refreshInterval];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0) {
        // 关于
        FMAboutViewController *aboutVC = [[FMAboutViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
    } else if (indexPath.row == 2) {
        // 刷新频率
        FMRefreshIntervalViewController *intervalVC = [[FMRefreshIntervalViewController alloc] init];
        [self.navigationController pushViewController:intervalVC animated:YES];
    }
}

#pragma mark - Actions

- (void)appearanceSwitchChanged:(UISwitch *)sender {
    [FMSettingsManager sharedManager].followSystemAppearance = sender.on;
    [[FMSettingsManager sharedManager] saveSettings];

    // 发送通知，让 TabBarController 更新主题
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppearanceSettingDidChange" object:nil];
}

@end
