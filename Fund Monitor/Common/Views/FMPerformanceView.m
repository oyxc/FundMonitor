//
//  FMPerformanceView.m
//  Fund Monitor
//
//  单位净值（业绩走势）视图
//

#import "FMPerformanceView.h"
#import "FMHistoryDataTableView.h"
#import "FMNetWorthTrendData.h"

@interface FMPerformanceView ()

@property (nonatomic, strong, readwrite) FMHistoryDataTableView *tableView;
@property (nonatomic, strong, readwrite) UIButton *showMoreButton;
@property (nonatomic, strong) NSArray<FMNetWorthTrendData *> *fullHistoryData;

@end

@implementation FMPerformanceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor systemBackgroundColor];

    CGFloat width = self.bounds.size.width;
    CGFloat yOffset = 10;

    // 历史数据表格
    self.tableView = [[FMHistoryDataTableView alloc] initWithFrame:CGRectMake(0, yOffset, width, 320)];
    [self addSubview:self.tableView];
    yOffset += 270;

    // 显示更多按钮
    self.showMoreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.showMoreButton.frame = CGRectMake(0, yOffset, width, 44);
    [self.showMoreButton setTitle:@"显示更多>>" forState:UIControlStateNormal];
    self.showMoreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.showMoreButton addTarget:self action:@selector(showMoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.showMoreButton];
    yOffset += 44;
}

- (void)updateWithHistoryData:(NSArray<FMNetWorthTrendData *> *)historyData {
    self.fullHistoryData = historyData;

    // 初始显示5条
    NSArray *displayData = historyData;
    if (historyData.count > 5) {
        displayData = [historyData subarrayWithRange:NSMakeRange(historyData.count-5, 5)];
        displayData = displayData.reverseObjectEnumerator.allObjects;
        self.showMoreButton.hidden = NO;
    } else {
        self.showMoreButton.hidden = YES;
    }

    self.tableView.historyData = displayData;
    [self.tableView reloadData];
}

- (void)showMoreButtonTapped:(UIButton *)sender {
    // 触发回调，让父视图控制器处理
    if (self.showMoreButtonTappedBlock) {
        self.showMoreButtonTappedBlock();
    }
}

@end
