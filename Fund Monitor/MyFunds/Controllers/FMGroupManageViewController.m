//
//  FMGroupManageViewController.m
//  FundMonitor
//

#import "FMGroupManageViewController.h"
#import "FMDataManager.h"

@interface FMGroupManageViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<FMGroup *> *groups;

@end

@implementation FMGroupManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"分组管理";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupNavigationBar];
    [self setupUI];
    [self loadData];

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
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addGroupAction)];
    self.navigationItem.rightBarButtonItem = addItem;
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tableView];

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)loadData {
    self.groups = [[[FMDataManager sharedManager] getAllGroups] mutableCopy];
    [self.tableView reloadData];
}

- (void)addGroupAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新建分组"
                                                                   message:@"请输入分组名称"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"分组名称";
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *groupName = textField.text;

        if (groupName.length > 0) {
            FMGroup *group = [FMGroup groupWithName:groupName];
            BOOL success = [[FMDataManager sharedManager] addGroup:group];

            if (success) {
                [self loadData];
            } else {
                [self showAlertWithMessage:@"添加失败"];
            }
        } else {
            [self showAlertWithMessage:@"分组名称不能为空"];
        }
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)editGroupAtIndex:(NSInteger)index {
    FMGroup *group = self.groups[index];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"编辑分组"
                                                                   message:@"请输入新的分组名称"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"分组名称";
        textField.text = group.groupName;
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *newName = textField.text;

        if (newName.length > 0) {
            group.groupName = newName;
            BOOL success = [[FMDataManager sharedManager] updateGroup:group];

            if (success) {
                [self loadData];
            } else {
                [self showAlertWithMessage:@"修改失败"];
            }
        } else {
            [self showAlertWithMessage:@"分组名称不能为空"];
        }
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteGroupAtIndex:(NSInteger)index {
    FMGroup *group = self.groups[index];

    if ([group.groupId isEqualToString:@"default"]) {
        [self showAlertWithMessage:@"默认分组不能删除"];
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除"
                                                                   message:[NSString stringWithFormat:@"确定要删除分组 \"%@\" 吗？\n该分组下的基金将移到默认分组", group.groupName]
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        BOOL success = [[FMDataManager sharedManager] removeGroup:group.groupId];

        if (success) {
            [self loadData];
        } else {
            [self showAlertWithMessage:@"删除失败"];
        }
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    FMGroup *group = self.groups[indexPath.row];
    cell.textLabel.text = group.groupName;

    // 显示该分组下的基金数量
    NSArray *funds = [[FMDataManager sharedManager] getFundsInGroup:group.groupId];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld 只基金", (long)funds.count];

    // 所有分组都显示可编辑标识
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 所有分组都支持点击编辑
    [self editGroupAtIndex:indexPath.row];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMGroup *group = self.groups[indexPath.row];

    // 编辑操作（所有分组都支持）
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                             title:@"编辑"
                                                                           handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        [self editGroupAtIndex:indexPath.row];
        completionHandler(YES);
    }];
    editAction.backgroundColor = [UIColor systemBlueColor];

    // 默认分组只显示编辑按钮
    if ([group.groupId isEqualToString:@"default"]) {
        UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[editAction]];
        return config;
    }

    // 非默认分组显示编辑和删除按钮
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                               title:@"删除"
                                                                             handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        [self deleteGroupAtIndex:indexPath.row];
        completionHandler(YES);
    }];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, editAction]];
    return config;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // 所有分组都允许滑动操作（编辑）
    return YES;
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    [self.tableView reloadData];
}

@end
