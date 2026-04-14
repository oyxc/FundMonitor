//
//  FMGroupSelectionView.m
//  FundMonitor
//
//  底部分组选择弹窗
//

#import "FMGroupSelectionView.h"
#import "FMDataManager.h"

@interface FMGroupSelectionView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSArray<FMGroup *> *groups;
@property (nonatomic, strong) NSMutableSet<NSString *> *selectedGroupIds;
@property (nonatomic, strong) FMFund *fund;

@end

@implementation FMGroupSelectionView

- (instancetype)initWithGroups:(NSArray<FMGroup *> *)groups fund:(FMFund *)fund selectedGroupIds:(NSSet<NSString *> *)selectedIds {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.fund = fund;
        self.groups = groups;
        self.selectedGroupIds = selectedIds ? [selectedIds mutableCopy] : [NSMutableSet set];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];

    // 容器视图（用于点击背景关闭）
    self.containerView = [[UIView alloc] initWithFrame:self.bounds];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.containerView];

    // 添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.containerView addGestureRecognizer:tapGesture];

    // 内容视图
    CGFloat contentHeight = MIN(500, self.bounds.size.height * 0.7);
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, contentHeight)];
    self.contentView.backgroundColor = [UIColor systemBackgroundColor];
    self.contentView.layer.cornerRadius = 16;
    self.contentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self addSubview:self.contentView];

    // 标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.contentView.bounds.size.width - 40, 24)];
    self.titleLabel.text = @"选择分组";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];

    // 提示文字
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, self.contentView.bounds.size.width - 40, 20)];
    hintLabel.text = @"可以选择多个分组";
    hintLabel.font = [UIFont systemFontOfSize:14];
    hintLabel.textColor = [UIColor secondaryLabelColor];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:hintLabel];

    // 表格视图
    CGFloat tableHeight = contentHeight - 180;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, self.contentView.bounds.size.width, tableHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"GroupCell"];
    [self.contentView addSubview:self.tableView];

    // 按钮容器
    CGFloat buttonY = 80 + tableHeight + 10;
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(20, buttonY, self.contentView.bounds.size.width - 40, 50)];
    [self.contentView addSubview:buttonContainer];

    // 取消按钮
    CGFloat buttonWidth = (buttonContainer.bounds.size.width - 10) / 2;
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.cancelButton.frame = CGRectMake(0, 0, buttonWidth, 44);
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.cancelButton.layer.cornerRadius = 8;
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.layer.borderColor = [UIColor systemGrayColor].CGColor;
    [self.cancelButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:self.cancelButton];

    // 确定按钮
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.confirmButton.frame = CGRectMake(buttonWidth + 10, 0, buttonWidth, 44);
    [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    self.confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.confirmButton.backgroundColor = [UIColor systemBlueColor];
    self.confirmButton.layer.cornerRadius = 8;
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:self.confirmButton];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell" forIndexPath:indexPath];

    FMGroup *group = self.groups[indexPath.row];
    BOOL isSelected = [self.selectedGroupIds containsObject:group.groupId];

    // 设置文本
    cell.textLabel.text = group.groupName;
    cell.textLabel.font = [UIFont systemFontOfSize:16];

    // 设置选中状态
    if (isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor labelColor];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FMGroup *group = self.groups[indexPath.row];

    // 切换选中状态
    if ([self.selectedGroupIds containsObject:group.groupId]) {
        [self.selectedGroupIds removeObject:group.groupId];
    } else {
        [self.selectedGroupIds addObject:group.groupId];
    }

    // 刷新单元格
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Actions

- (void)confirmButtonTapped {
    if (self.selectedGroupIds.count == 0) {
        // 显示提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"请至少选择一个分组"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];

        // 获取当前的 window 和 rootViewController
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
        return;
    }

    // 获取选中的分组对象
    NSMutableArray<FMGroup *> *selectedGroups = [NSMutableArray array];
    for (FMGroup *group in self.groups) {
        if ([self.selectedGroupIds containsObject:group.groupId]) {
            [selectedGroups addObject:group];
        }
    }

    //添加到分组
    [self addFundToGroups:selectedGroups];

    [self dismiss];
}

- (void)addFundToGroups:(NSArray<FMGroup *> *)groups {
    NSMutableArray *successGroups = [NSMutableArray array];
    NSMutableArray *failedGroups = [NSMutableArray array];
    
    for (FMGroup *group in groups) {
        BOOL success = [[FMDataManager sharedManager] addSelectedFund:self.fund toGroup:group.groupId];
        if (success) {
            [successGroups addObject:group.groupName];
        } else {
            [failedGroups addObject:group.groupName];
        }
    }
    
    // 显示结果
    NSString *message = @"";
    if (successGroups.count > 0) {
        message = [NSString stringWithFormat:@"已添加到：%@", [successGroups componentsJoinedByString:@"、"]];
    }
    if (failedGroups.count > 0) {
        if (message.length > 0) {
            message = [message stringByAppendingString:@"\n"];
        }
        message = [message stringByAppendingFormat:@"添加失败：%@", [failedGroups componentsJoinedByString:@"、"]];
    }
    
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(groupSelectionFinishWithMessage:)]) {
        [self.delegate groupSelectionFinishWithMessage:message];
    }
}

- (void)cancelButtonTapped {
    [self dismiss];
}

- (void)backgroundTapped {
    [self dismiss];
}

#pragma mark - Show/Dismiss

- (void)show {
    // 添加到 window
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    [window addSubview:self];

    // 动画显示
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        CGRect frame = self.contentView.frame;
        frame.origin.y = self.bounds.size.height - frame.size.height;
        self.contentView.frame = frame;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        CGRect frame = self.contentView.frame;
        frame.origin.y = self.bounds.size.height;
        self.contentView.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
