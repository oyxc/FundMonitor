//
//  FMFundChartView.m
//  FundMonitor
//
//  图表视图 - 使用 DGCharts 显示基金净值走势
//

#import "FMFundChartView.h"
#import "FMFundHistoryData.h"
#import "FMNetWorthTrendData.h"
#import "FMGrandTotalData.h"
#import "FMCrosshairMarker.h"
#import "FMCrosshairView.h"
#import <DGCharts/DGCharts-Swift.h>

// Y轴自定义格式化器
@interface FMYAxisValueFormatter : NSObject <ChartAxisValueFormatter>
@property (nonatomic, assign) BOOL isPercentage; // 是否显示为百分比
@end

@implementation FMYAxisValueFormatter

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    if (self.isPercentage) {
        return [NSString stringWithFormat:@"%.2f%%", value];
    } else {
        return [NSString stringWithFormat:@"%.4f", value];
    }
}

@end

// X轴自定义格式化器 - 只显示指定索引的标签
@interface FMXAxisValueFormatter : NSObject <ChartAxisValueFormatter>
@property (nonatomic, strong) NSArray<NSString *> *dateStrings; // 所有日期字符串
@property (nonatomic, assign) NSInteger labelCount; // 标签数量
@property (nonatomic, assign) NSInteger dataCount; // 数据总数
@end

@implementation FMXAxisValueFormatter

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis {
    NSInteger index = (NSInteger)round(value);

    if (index >= 0 && index < self.dateStrings.count) {
        return self.dateStrings[index];
    }

    return @"";
}

@end

@interface FMFundChartView () <ChartViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) LineChartView *chartView;
@property (nonatomic, strong) FMCrosshairView *crosshairView;
@property (nonatomic, strong) NSArray<NSString *> *currentDateLabels;  // 当前显示的日期标签
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;  // 长按手势
@property (nonatomic, assign) BOOL isDragging;  // 是否正在拖动
@property (nonatomic, assign) BOOL isLongPressing;  // 是否正在长按
@property (nonatomic, strong) NSArray *showDataList;  // 当前显示的数据列表
@end

@implementation FMFundChartView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor systemBackgroundColor];
    self.isDragging = NO;
    self.isLongPressing = NO;

    // 创建图表视图
    self.chartView = [[LineChartView alloc] init];
    self.chartView.delegate = self;
    self.chartView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.chartView];

    // 创建十字线覆盖视图
    self.crosshairView = [[FMCrosshairView alloc] init];
    self.crosshairView.translatesAutoresizingMaskIntoConstraints = NO;
    self.crosshairView.userInteractionEnabled = NO;  // 不拦截触摸事件
    [self addSubview:self.crosshairView];

    // 添加长按手势识别器
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    self.longPressGesture.minimumPressDuration = 0.2;  // 长按触发时间
    self.longPressGesture.delegate = self;
    [self.chartView addGestureRecognizer:self.longPressGesture];

    // 布局约束
    [NSLayoutConstraint activateConstraints:@[
        [self.chartView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.chartView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.chartView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.chartView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

        [self.crosshairView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.crosshairView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.crosshairView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.crosshairView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];

    // 配置图表样式
    [self configureChartStyle];
}

- (void)configureChartStyle {
    // 基本配置
    self.chartView.chartDescription.enabled = NO;
    self.chartView.dragEnabled = YES;  // 启用拖动以支持触摸交互
    self.chartView.pinchZoomEnabled = NO;  // 禁用缩放
    self.chartView.doubleTapToZoomEnabled = NO;  // 禁用双击缩放
    self.chartView.scaleXEnabled = NO;  // 禁用X轴缩放
    self.chartView.scaleYEnabled = NO;  // 禁用Y轴缩放
    self.chartView.drawGridBackgroundEnabled = NO;
    self.chartView.legend.enabled = YES;
    self.chartView.legend.form = ChartLegendFormLine;

    // 启用高亮功能
    self.chartView.highlightPerTapEnabled = NO;
    self.chartView.highlightPerDragEnabled = NO;
    self.chartView.drawMarkers = NO;  // 禁用内置 marker，使用自定义的
    self.chartView.maxHighlightDistance = 500.0;  // 增加点击检测范围（像素）

    // X轴配置
    ChartXAxis *xAxis = self.chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.granularity = 1.0;
    xAxis.labelTextColor = [UIColor secondaryLabelColor];
    xAxis.labelCount = 3;  // 固定显示3个标签
    xAxis.forceLabelsEnabled = YES;  // 强制显示指定数量的标签
    xAxis.avoidFirstLastClippingEnabled = YES;  // 避免首尾标签被裁剪
    xAxis.drawLimitLinesBehindDataEnabled = YES;

    // 左Y轴配置
    ChartYAxis *leftAxis = self.chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.gridColor = [[UIColor separatorColor] colorWithAlphaComponent:0.3];
    leftAxis.labelTextColor = [UIColor secondaryLabelColor];

    // 固定显示5个标签
    leftAxis.labelCount = 5;
    leftAxis.forceLabelsEnabled = YES;
    leftAxis.drawTopYLabelEntryEnabled = YES;  // 显示顶部标签
    leftAxis.drawBottomYLabelEntryEnabled = YES;  // 显示底部标签

    // 设置Y轴自定义格式化器（默认不显示百分比）
    FMYAxisValueFormatter *yAxisFormatter = [[FMYAxisValueFormatter alloc] init];
    yAxisFormatter.isPercentage = YES;
    leftAxis.valueFormatter = yAxisFormatter;

    // 右Y轴配置
    self.chartView.rightAxis.enabled = NO;

    // 设置右边间距，防止X轴最后一个标签显示不全
    self.chartView.extraRightOffset = 20.0;
}

// 使用净值走势数据更新图表
- (void)updateChartWithNetWorthTrendData:(NSInteger)startTime {
    if (!self.netWorthTrendData || self.netWorthTrendData.count == 0) {
        self.chartView.data = nil;
        [self.chartView notifyDataSetChanged];
        self.showDataList = nil;
        return;
    }

    // 数据优化：过滤掉日期小于最后一天日期的前置数据
    NSArray *filteredData = [self filterDataByLastDayOfMonth:self.netWorthTrendData startTime:startTime];
    if (filteredData.count == 0) {
        self.chartView.data = nil;
        [self.chartView notifyDataSetChanged];
        self.showDataList = nil;
        return;
    }

    // 净值图表使用百分比格式
    FMYAxisValueFormatter *yAxisFormatter = [[FMYAxisValueFormatter alloc] init];
    yAxisFormatter.isPercentage = YES;
    self.chartView.leftAxis.valueFormatter = yAxisFormatter;

    // 准备数据
    NSMutableArray *dataList = [NSMutableArray array];
    NSMutableArray<ChartDataEntry *> *entries = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];

    // 获取第一个净值作为基准
    double baseNetWorth = 0;
    for (FMNetWorthTrendData *data in filteredData) {
        if (data.netWorth) {
            baseNetWorth = [data.netWorth doubleValue];
            break;
        }
    }

    if (baseNetWorth == 0) {
        self.chartView.data = nil;
        [self.chartView notifyDataSetChanged];
        return;
    }

    // 计算相对于第一个净值的百分比变化，并赋值给 model
    for (NSInteger i = 0; i < filteredData.count; i++) {
        FMNetWorthTrendData *data = filteredData[i];
        if (data.netWorth) {
            double currentNetWorth = [data.netWorth doubleValue];
            // 计算百分比变化: ((当前值 - 基准值) / 基准值) * 100
            double percentageChange = ((currentNetWorth - baseNetWorth) / baseNetWorth) * 100.0;

            // 将累计涨幅赋值给 model
            data.cumulativeChange = @(percentageChange);

            ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:i y:percentageChange];
            [entries addObject:entry];
            [dataList addObject:data];
            [valueList addObject:@(percentageChange)];
        }
    }
    self.showDataList = dataList;

    if (entries.count == 0) {
        self.chartView.data = nil;
        [self.chartView notifyDataSetChanged];
        return;
    }

    // 创建数据集
    LineChartDataSet *dataSet = [[LineChartDataSet alloc] initWithEntries:entries label:@"单位净值"];

    // 配置数据集样式
    dataSet.drawCirclesEnabled = NO;  // 不显示数据点圆圈
    dataSet.drawValuesEnabled = NO;   // 不显示数值标签
    dataSet.lineWidth = 2.0;
    dataSet.mode = LineChartModeLinear;  // 折线

    // 设置线条颜色（蓝色）
    dataSet.colors = @[[UIColor systemBlueColor]];

    // 设置填充颜色
    dataSet.drawFilledEnabled = YES;
    dataSet.fillColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.2];
    dataSet.fillAlpha = 0.5;

    // 创建图表数据
    LineChartData *chartData = [[LineChartData alloc] initWithDataSet:dataSet];

    // 设置数据到图表
    self.chartView.data = chartData;

    // 配置X轴标签（使用过滤后的数据）
    [self configureXAxisLabelsForNetWorthTrendWithData:filteredData];

    // 重置缩放，确保所有数据可见
    [self.chartView fitScreen];

    // 设置可见范围为所有数据
    [self.chartView setVisibleXRangeMaximum:entries.count];
    [self.chartView setVisibleXRangeMinimum:entries.count];

    // 刷新图表
    [self.chartView notifyDataSetChanged];
    [self.chartView animateWithXAxisDuration:1.0];
}

// 配置净值走势数据的X轴标签
- (void)configureXAxisLabelsForNetWorthTrendWithData:(NSArray *)dataArray {
    if (!dataArray || dataArray.count == 0) {
        return;
    }

    ChartXAxis *xAxis = self.chartView.xAxis;

    // 获取所有日期字符串
    NSMutableArray<NSString *> *allDateStrings = [NSMutableArray array];
    for (FMNetWorthTrendData *data in dataArray) {
        if (data.dateString && data.dateString.length >= 10) {
            [allDateStrings addObject:data.dateString];
        } else {
            [allDateStrings addObject:@""];
        }
    }

    // 创建自定义格式化器
    FMXAxisValueFormatter *formatter = [[FMXAxisValueFormatter alloc] init];
    formatter.dateStrings = allDateStrings;
    formatter.labelCount = 3;
    formatter.dataCount = dataArray.count;

    // 设置X轴标签格式化器
    xAxis.valueFormatter = formatter;

    // 设置 X 轴范围和标签
    xAxis.axisMinimum = 0;
    xAxis.axisMaximum = dataArray.count - 1;

    // 确保强制显示3个标签
    [xAxis setLabelCount:3 force:YES];
    xAxis.granularityEnabled = YES;
    xAxis.granularity = 1.0;
    xAxis.avoidFirstLastClippingEnabled = YES;

    // 保存当前日期标签（用于 marker 显示）
    self.currentDateLabels = allDateStrings;
}

// 获取净值走势数据的日期标签（固定3个：第一个、中间、最后一个）
- (NSArray<NSString *> *)getDateLabelsForNetWorthTrendWithData:(NSArray *)dataArray {
    NSMutableArray<NSString *> *labels = [NSMutableArray array];
    NSInteger dataCount = dataArray.count;

    if (dataCount == 0) {
        return labels;
    }

    // 固定显示3个标签：第一个(0)、中间、最后一个
    NSArray *indexList = [self getIndexListWithCount:3 dataCount:dataCount];

    // 为每个数据点创建标签
    for (NSInteger i = 0; i < dataCount; i++) {
        FMNetWorthTrendData *data = dataArray[i];
        if ([indexList containsObject:@(i)] && data.timestamp && data.dateString.length >= 10) {
            // 使用完整的日期字符串 yyyy-MM-dd
            NSString *dateString = data.dateString;
            [labels addObject:dateString];
        } else {
            [labels addObject:@""];
        }
    }

    return labels;
}

// - index均匀采样
- (NSArray *)getIndexListWithCount:(NSInteger)labelCount dataCount:(NSInteger)dataCount {
    NSInteger totalSteps = labelCount - 1;
    CGFloat totalDistance = (CGFloat)(dataCount - 1);
    CGFloat step = 1;
    if (totalDistance > 0 && totalSteps > 0 && totalDistance > totalSteps) {
        step = totalDistance / totalSteps;
    }
    NSMutableArray *indexArr = [NSMutableArray array];
    for (NSInteger i = 0; i < labelCount; i++) {
        NSInteger index = (NSInteger)round(i * step);
        [indexArr addObject:@(index)];
    }
    return indexArr;
}

// 使用累计收益数据更新图表（支持多条线对比）
- (void)updateChartWithGrandTotalDataByCount:(NSInteger)showCount startTime:(NSInteger)startTime {
    if (!self.grandTotalData || self.grandTotalData.count == 0) {
        self.chartView.data = nil;
        [self.chartView notifyDataSetChanged];
        return;
    }

    // 累计收益图表使用百分比格式
    FMYAxisValueFormatter *yAxisFormatter = [[FMYAxisValueFormatter alloc] init];
    yAxisFormatter.isPercentage = YES;
    self.chartView.leftAxis.valueFormatter = yAxisFormatter;

    NSMutableArray *dataList = [NSMutableArray array];
    NSMutableArray<LineChartDataSet *> *dataSets = [NSMutableArray array];
    NSInteger maxDataCount = 0;

    // 定义颜色数组（用于不同的数据集）
    NSArray<UIColor *> *colors = @[
        [UIColor systemBlueColor],                                      // 本基金 - 蓝色（保持原色）
        [[UIColor systemOrangeColor] colorWithAlphaComponent:0.5],     // 同类平均 - 橙色（调暗）
        [[UIColor systemGreenColor] colorWithAlphaComponent:0.5]       // 沪深300 - 绿色（调暗）
    ];

    // 遍历每个数据集（本基金、同类平均、沪深300等）
    for (NSInteger dataSetIndex = 0; dataSetIndex < self.grandTotalData.count; dataSetIndex++) {
        FMGrandTotalData *grandTotal = self.grandTotalData[dataSetIndex];

        if (!grandTotal.data || grandTotal.data.count == 0) {
            continue;
        }

        // 准备数据点
        NSMutableArray<ChartDataEntry *> *entries = [NSMutableArray array];
        NSInteger totalCount = grandTotal.data.count;
        NSInteger dataCount = MIN(showCount, totalCount);

        NSArray *netData = [grandTotal.data subarrayWithRange:NSMakeRange(totalCount - dataCount, dataCount)];

        // 数据优化：过滤掉日期小于最后一天日期的前置数据
        netData = [self filterDataByLastDayOfMonth:netData startTime:startTime];
        if (netData.count == 0) {
            continue;
        }

        // 获取区间第一个数据作为基准
        double baseValue = 0;
        if (netData.count > 0) {
            FMGrandTotalDataItem *firstItem = netData.firstObject;
            baseValue = [firstItem.totalReturn doubleValue];
        }

        // 计算相对于第一天的累计涨幅，并赋值给 model
        for (NSInteger i = 0; i < netData.count; i++) {
            FMGrandTotalDataItem *item = netData[i];
            if (item.totalReturn) {
                double currentValue = [item.totalReturn doubleValue];
                // 计算相对于区间第一天的累计涨幅
                double cumulativeChange = currentValue - baseValue;

                // 将累计涨幅赋值给 model
                item.cumulativeChange = @(cumulativeChange);

                ChartDataEntry *entry = [[ChartDataEntry alloc] initWithX:i y:cumulativeChange];
                [entries addObject:entry];
            }
        }

        [dataList addObject:netData];

        if (entries.count == 0) {
            continue;
        }

        // 记录最大数据点数量（用于X轴标签）
        if (netData.count > maxDataCount) {
            maxDataCount = netData.count;
        }

        // 创建数据集
        NSString *label = grandTotal.name ?: [NSString stringWithFormat:@"数据集%ld", (long)(dataSetIndex + 1)];
        LineChartDataSet *dataSet = [[LineChartDataSet alloc] initWithEntries:entries label:label];

        // 配置数据集样式
        dataSet.drawCirclesEnabled = NO;  // 不显示数据点圆圈
        dataSet.drawValuesEnabled = NO;   // 不显示数值标签
        dataSet.lineWidth = dataSetIndex > 0 ? 1.0: 2.0;
        dataSet.mode = LineChartModeLinear;  // 折线

        // 设置线条颜色
        UIColor *color = colors[MIN(dataSetIndex, colors.count - 1)];
        dataSet.colors = @[color];

        // 第一条线（本基金）显示填充，其他线不显示填充
        if (dataSetIndex == 0) {
            dataSet.drawFilledEnabled = YES;
            dataSet.fillColor = [color colorWithAlphaComponent:0.2];
            dataSet.fillAlpha = 0.5;
        } else {
            dataSet.drawFilledEnabled = NO;
        }

        [dataSets addObject:dataSet];
    }
    self.showDataList = dataList;

    if (dataSets.count == 0) {
        self.chartView.data = nil;
        [self.chartView notifyDataSetChanged];
        return;
    }

    // 创建图表数据
    LineChartData *chartData = [[LineChartData alloc] initWithDataSets:dataSets];

    // 设置数据到图表
    self.chartView.data = chartData;

    // 配置X轴标签
    [self configureXAxisLabelsForGrandTotal];

    // 重置缩放，确保所有数据可见
    [self.chartView fitScreen];

    // 设置可见范围为所有数据
    [self.chartView setVisibleXRangeMaximum:maxDataCount];
    [self.chartView setVisibleXRangeMinimum:maxDataCount];

    // 刷新图表
    [self.chartView notifyDataSetChanged];
    [self.chartView animateWithXAxisDuration:1.0];
}

// 配置累计收益数据的X轴标签
- (void)configureXAxisLabelsForGrandTotal {
    NSArray *list = (NSArray *)self.showDataList.firstObject;
    if (!list || list.count == 0) {
        return;
    }

    ChartXAxis *xAxis = self.chartView.xAxis;

    // 获取所有日期字符串
    NSMutableArray<NSString *> *allDateStrings = [NSMutableArray array];
    for (FMGrandTotalDataItem *item in list) {
        if (item.dateString && item.dateString.length >= 10) {
            [allDateStrings addObject:item.dateString];
        } else {
            [allDateStrings addObject:@""];
        }
    }

    // 创建自定义格式化器
    FMXAxisValueFormatter *formatter = [[FMXAxisValueFormatter alloc] init];
    formatter.dateStrings = allDateStrings;
    formatter.labelCount = 3;
    formatter.dataCount = list.count;

    // 设置X轴标签格式化器
    xAxis.valueFormatter = formatter;

    // 设置 X 轴范围和标签
    xAxis.axisMinimum = 0;
    xAxis.axisMaximum = list.count - 1;

    // 确保强制显示3个标签
    [xAxis setLabelCount:3 force:YES];
    xAxis.granularityEnabled = YES;
    xAxis.granularity = 1.0;
    xAxis.avoidFirstLastClippingEnabled = YES;

    // 保存当前日期标签（用于 marker 显示）
    self.currentDateLabels = allDateStrings;
}

// 获取累计收益数据的日期标签（固定3个：第一个、中间、最后一个）
- (NSArray<NSString *> *)getDateLabelsForGrandTotalWithList:(NSArray *)list {
    NSMutableArray<NSString *> *labels = [NSMutableArray array];
    if (!list || list.count == 0) {
        return labels;
    }

    NSInteger dataCount = list.count;

    // 固定显示3个标签：第一个(0)、中间、最后一个
    NSArray *indexList = [self getIndexListWithCount:3 dataCount:dataCount];

    // 为每个数据点创建标签
    for (NSInteger i = 0; i < dataCount; i++) {
        FMGrandTotalDataItem *item = list[i];
        if ([indexList containsObject:@(i)] && item.timestamp && item.dateString.length >= 10) {
            // 使用完整的日期字符串 yyyy-MM-dd
            NSString *dateString = item.dateString;
            [labels addObject:dateString];
        } else {
            [labels addObject:@""];
        }
    }

    return labels;
}

#pragma mark - Gesture Handler

// 长按手势处理
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
//    CGPoint touchPoint = [gesture locationInView:self.chartView];
//    ChartHighlight *highlight = [self findNearestHighlightForPoint:touchPoint];

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"handleLongPressGesture Began");
            // 长按开始，显示marker
            self.chartView.highlightPerDragEnabled = YES;
            self.isLongPressing = YES;
            break;

        case UIGestureRecognizerStateChanged:
            NSLog(@"handleLongPressGesture Move");
            break;

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            NSLog(@"handleLongPressGesture Ended");
            // 长按结束，隐藏marker
            self.chartView.highlightPerDragEnabled = NO;
            self.isLongPressing = NO;
            [self hideCrosshair];
            break;

        default:
            break;
    }
}

// 查找离点击位置最近的数据点（只考虑 X 轴）
- (ChartHighlight *)findNearestHighlightForPoint:(CGPoint)point {
    LineChartData *data = self.chartView.lineData;
    if (!data || data.dataSetCount == 0) {
        return nil;
    }

    LineChartDataSet *dataSet = (LineChartDataSet *)[data dataSets].firstObject;
    if (!dataSet || dataSet.entryCount == 0) {
        return nil;
    }

    // 获取 transformer 用于坐标转换
    ChartTransformer *transformer = [self.chartView getTransformerForAxis:AxisDependencyLeft];

    // 将点击位置转换为图表值
    CGPoint valuePoint = [transformer valueForTouchPoint:point];

    // 找到最近的 X 值（四舍五入）
    NSInteger nearestIndex = (NSInteger)round(valuePoint.x);

    // 确保索引在有效范围内
    if (nearestIndex < 0) {
        nearestIndex = 0;
    } else if (nearestIndex >= dataSet.entryCount) {
        nearestIndex = dataSet.entryCount - 1;
    }

    // 获取该索引的数据点
    ChartDataEntry *entry = [dataSet entryForIndex:nearestIndex];
    if (!entry) {
        return nil;
    }

    // 创建高亮对象（使用完整的初始化方法，xPx 和 yPx 使用点击位置）
    ChartHighlight *highlight = [[ChartHighlight alloc] initWithX:entry.x
                                                                 y:entry.y
                                                         xPx:point.x
                                                         yPx:point.y
                                                  dataSetIndex:0
                                                   stackIndex:-1
                                                          axis:AxisDependencyLeft];

    return highlight;
}

#pragma mark - Data Filter

// 过滤数据：剔除日期小于最后一天日期的前置数据
- (NSArray *)filterDataByLastDayOfMonth:(NSArray *)dataArray startTime:(NSInteger)startTime {
    if (!dataArray || dataArray.count == 0 || startTime == 0) {
        return dataArray;
    }
    
    NSInteger startIndex = 0;
    for (FMNetWorthTrendData *netModel in dataArray) {
        if (netModel.dateStringInt >= startTime) {
            startIndex = [dataArray indexOfObject:netModel];
            break;
        }
    }
    
    dataArray = [dataArray subarrayWithRange:NSMakeRange(startIndex, dataArray.count - startIndex)];

    return dataArray;
}

// 从日期字符串中提取天数（格式：yyyy-MM-dd）
- (NSInteger)getDayOfMonthFromDateString:(NSString *)dateString {
    if (!dateString || dateString.length < 10) {
        return 0;
    }

    // 提取日期部分（最后两位）
    NSString *dayString = [dateString substringFromIndex:8]; // "2024-04-22" -> "22"
    return [dayString integerValue];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 允许手势识别器与图表的手势同时工作
    return YES;
}

- (void)hideCrosshair {
    // 清除图表的高亮
    [self.chartView highlightValue:nil];

    // 隐藏十字线
    [self.crosshairView hideCrosshair];
    
    if (self.selectBlock) {
        self.selectBlock(nil);
    }
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry highlight:(ChartHighlight *)highlight {

    CGFloat value = 0;
    if (self.selectBlock) {
        NSInteger index = (NSInteger)entry.x;

        if ([self.showDataList.firstObject isKindOfClass:NSArray.class]) {
            //多个走势图
            NSMutableArray *result = [NSMutableArray array];
            for (NSArray *list in self.showDataList) {
                if (list.count > index) {
                    [result addObject:list[index]];
                }
            }
            self.selectBlock(result);

            FMGrandTotalDataItem *first = result.firstObject;
            value = first.totalReturn.doubleValue;

        } else {
            if (self.showDataList.count > index) {
                self.selectBlock(self.showDataList[index]);
            }

            FMNetWorthTrendData *first = self.showDataList[index];
            value = first.netWorth.doubleValue;
        }
    }

    // 使用 highlight 中的坐标信息
    CGPoint point = CGPointMake(highlight.xPx, highlight.yPx);

    // 只有长按手势（isLongPressing=YES）时才显示marker
    if (self.isLongPressing) {
        // 显示十字线
        [self.crosshairView setCrosshairAtPoint:point];
    }
    
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase *)chartView {
    // 触摸结束（滑动结束）时隐藏marker和十字线
    if (!self.isLongPressing) {
        [self hideCrosshair];
    }
}

@end
