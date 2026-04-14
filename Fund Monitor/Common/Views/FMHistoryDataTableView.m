//
//  FMHistoryDataTableView.m
//  FundMonitor
//
//  历史数据表格 - 显示历史净值数据列表
//

#import "FMHistoryDataTableView.h"
#import "FMNetWorthTrendData.h"

@interface FMHistoryDataTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FMHistoryDataTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor systemBackgroundColor];

    // 创建表格视图
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 44;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor systemBackgroundColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];

    // 布局约束
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];

    // 添加表头
    [self setupTableHeader];
}

- (void)setupTableHeader {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    headerView.backgroundColor = [UIColor secondarySystemBackgroundColor];

    // 日期标签
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 40)];
    dateLabel.text = @"日期";
    dateLabel.font = [UIFont boldSystemFontOfSize:14];
    dateLabel.textColor = [UIColor secondaryLabelColor];
    [headerView addSubview:dateLabel];

    // 净值标签
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 100, 40)];
    valueLabel.text = @"净值";
    valueLabel.font = [UIFont boldSystemFontOfSize:14];
    valueLabel.textColor = [UIColor secondaryLabelColor];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:valueLabel];

    // 日涨幅标签
    UILabel *rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 115, 0, 100, 40)];
    rateLabel.text = @"日涨幅";
    rateLabel.font = [UIFont boldSystemFontOfSize:14];
    rateLabel.textColor = [UIColor secondaryLabelColor];
    rateLabel.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:rateLabel];

    self.tableView.tableHeaderView = headerView;
}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HistoryDataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        // 日期标签
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.tag = 100;
        dateLabel.font = [UIFont systemFontOfSize:14];
        dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:dateLabel];

        // 净值标签
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.tag = 101;
        valueLabel.font = [UIFont systemFontOfSize:14];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:valueLabel];

        // 日涨幅标签
        UILabel *rateLabel = [[UILabel alloc] init];
        rateLabel.tag = 102;
        rateLabel.font = [UIFont systemFontOfSize:14];
        rateLabel.textAlignment = NSTextAlignmentRight;
        rateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:rateLabel];

        // 布局约束
        [NSLayoutConstraint activateConstraints:@[
            // 日期标签
            [dateLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15],
            [dateLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [dateLabel.widthAnchor constraintEqualToConstant:100],

            // 净值标签
            [valueLabel.leadingAnchor constraintEqualToAnchor:dateLabel.trailingAnchor constant:5],
            [valueLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [valueLabel.widthAnchor constraintEqualToConstant:100],

            // 日涨幅标签
            [rateLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-15],
            [rateLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [rateLabel.widthAnchor constraintEqualToConstant:100]
        ]];
    }

    // 获取数据
    FMNetWorthTrendData *data = self.historyData[indexPath.row];

    // 更新标签
    UILabel *dateLabel = [cell.contentView viewWithTag:100];
    UILabel *valueLabel = [cell.contentView viewWithTag:101];
    UILabel *rateLabel = [cell.contentView viewWithTag:102];

    dateLabel.text = data.dateString ?: @"--";
    valueLabel.text = data.netWorth ? [NSString stringWithFormat:@"%.4f", [data.netWorth doubleValue]] : @"--";

    if (data.equityReturn) {
        double rate = [data.equityReturn doubleValue];
        NSString *sign = rate >= 0 ? @"+" : @"";
        rateLabel.text = [NSString stringWithFormat:@"%@%.2f%%", sign, rate];

        if (rate > 0) {
            rateLabel.textColor = [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0];  // 红色（涨）
        } else if (rate < 0) {
            rateLabel.textColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0];  // 绿色（跌）
        } else {
            rateLabel.textColor = [UIColor labelColor];
        }
    } else {
        rateLabel.text = @"--";
        rateLabel.textColor = [UIColor labelColor];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 可以在这里添加点击事件处理
}

@end
