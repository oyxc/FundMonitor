# DGCharts 时间轴绘制原理说明

## 核心文件位置

```
Pods/DGCharts/Source/Charts/
├── Components/
│   ├── AxisBase.swift          # 轴基类，定义通用属性
│   └── XAxis.swift              # X轴类，继承自AxisBase
├── Renderers/
│   └── XAxisRenderer.swift      # X轴渲染器，负责绘制
└── Formatters/
    ├── AxisValueFormatter.swift      # 格式化器协议
    └── IndexAxisValueFormatter.swift # 索引格式化器（我们使用的）
```

## 工作流程

### 1. 标签数量计算 (AxisBase.swift)

```swift
// 默认标签数量
private var _labelCount = Int(6)

// labelCount 属性控制显示多少个标签
@objc open var labelCount: Int {
    get { return _labelCount }
    set { _labelCount = max(2, newValue) }
}
```

### 2. 轴值计算 (XAxisRenderer.swift)

```swift
open func computeAxisValues(min: Double, max: Double) {
    let labelCount = axis.labelCount
    let range = abs(yMax - yMin)

    // 计算标签间隔
    let rawInterval = range / Double(labelCount)
    var interval = rawInterval.roundedToNextSignificant()

    // 如果启用了 granularity，确保间隔不小于指定值
    if axis.granularityEnabled {
        interval = Swift.max(interval, axis.granularity)
    }

    // 生成 entries 数组（实际显示的轴值位置）
    for i in 0..<labelCount {
        let value = min + Double(i) * interval
        axis.entries.append(value)
    }
}
```

### 3. 标签格式化 (IndexAxisValueFormatter.swift)

```swift
open func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    // value 是轴上的数值位置（0, 1, 2, 3...）
    let index = Int(value.rounded())

    // 检查索引是否在 values 数组范围内
    guard values.indices.contains(index), index == Int(value) else {
        return ""
    }

    // 返回对应索引的标签文本
    return values[index]
}
```

**关键点**：
- `value` 参数是数据点的索引（0, 1, 2, 3...）
- `values` 数组必须与数据点数量一致
- 如果索引超出范围或不是整数，返回空字符串

### 4. 标签绘制 (XAxisRenderer.swift)

```swift
open func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint) {
    let entries = axis.entries  // 从 computeAxisValues 计算出的位置

    for i in entries.indices {
        let px = CGFloat(entries[i])  // 获取X坐标
        let position = CGPoint(x: px, y: 0).applying(valueToPixelMatrix)

        // 检查是否在可见范围内
        guard viewPortHandler.isInBoundsX(position.x) else { continue }

        // 使用 valueFormatter 获取标签文本
        let label = axis.valueFormatter?.stringForValue(axis.entries[i], axis: axis) ?? ""

        // 绘制标签
        drawLabel(context: context, formattedLabel: label, x: position.x, y: pos, ...)
    }
}
```

## 我们的实现分析

### 当前代码

```objc
// FMFundChartView.m

- (void)configureXAxisLabels {
    ChartXAxis *xAxis = self.chartView.xAxis;
    NSInteger dataCount = self.historyData.count;
    NSInteger labelCount = 7;  // 固定显示7个标签

    // 设置格式化器
    xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc]
        initWithValues:[self getDateLabelsWithCount:labelCount]];

    // 设置标签数量
    xAxis.labelCount = labelCount;

    // 禁用 granularity
    xAxis.granularityEnabled = NO;
}

- (NSArray<NSString *> *)getDateLabelsWithCount:(NSInteger)labelCount {
    NSMutableArray<NSString *> *labels = [NSMutableArray array];
    NSInteger dataCount = self.historyData.count;

    // 先用空字符串填充所有位置
    for (NSInteger i = 0; i < dataCount; i++) {
        [labels addObject:@""];
    }

    // 计算标签间隔
    double interval = (double)(dataCount - 1) / (double)(labelCount - 1);

    // 在特定位置设置日期标签
    for (NSInteger i = 0; i < labelCount; i++) {
        NSInteger index = (NSInteger)round(i * interval);
        if (index >= dataCount) {
            index = dataCount - 1;
        }

        FMFundHistoryData *data = self.historyData[index];
        if (data.date) {
            NSArray *components = [data.date componentsSeparatedByString:@"-"];
            if (components.count >= 3) {
                NSString *label = [NSString stringWithFormat:@"%@-%@",
                    components[1], components[2]];
                labels[index] = label;
            }
        }
    }

    return labels;
}
```

### 工作原理

1. **数据点数量**：假设有 30 个数据点（近1月）
2. **标签数组大小**：创建 30 个元素的数组，初始全为空字符串
3. **计算显示位置**：
   - labelCount = 7
   - interval = (30 - 1) / (7 - 1) = 29 / 6 ≈ 4.83
   - 显示位置：0, 5, 10, 14, 19, 24, 29
4. **填充标签**：只在这7个位置填充实际日期，其他位置保持空字符串
5. **DGCharts 渲染**：
   - 计算出要显示的轴值位置（entries）
   - 对每个位置调用 `stringForValue(index)`
   - 如果 `labels[index]` 是空字符串，则不显示标签
   - 如果 `labels[index]` 有内容，则显示该日期

## 关键属性说明

### labelCount
- **类型**：`Int`
- **默认值**：6
- **作用**：控制 X 轴上显示多少个标签
- **影响**：决定 `computeAxisValues` 计算出多少个 `entries`

### granularityEnabled
- **类型**：`Bool`
- **默认值**：false
- **作用**：启用后，确保标签间隔不小于 `granularity` 值
- **我们的设置**：NO（禁用），让 DGCharts 自动计算间隔

### granularity
- **类型**：`Double`
- **默认值**：1.0
- **作用**：最小标签间隔
- **使用场景**：避免缩放时标签重复

### forceLabelsEnabled
- **类型**：`Bool`
- **默认值**：false
- **作用**：强制显示指定数量的标签
- **效果**：忽略 granularity，严格按 labelCount 显示

### entries
- **类型**：`[Double]`
- **作用**：存储实际要显示标签的轴值位置
- **生成**：由 `computeAxisValues` 方法计算

### valueFormatter
- **类型**：`AxisValueFormatter` 协议
- **作用**：将轴值（Double）转换为显示文本（String）
- **我们使用**：`IndexAxisValueFormatter`

## 优化建议

### 方案1：使用 forceLabelsEnabled（推荐）

```objc
- (void)configureXAxisLabels {
    ChartXAxis *xAxis = self.chartView.xAxis;
    NSInteger labelCount = 7;

    // 强制显示7个标签
    xAxis.forceLabelsEnabled = YES;
    xAxis.labelCount = labelCount;

    // 设置格式化器
    xAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc]
        initWithValues:[self getDateLabelsWithCount:labelCount]];
}
```

### 方案2：自定义 AxisValueFormatter

```objc
// 创建自定义格式化器类
@interface FMDateAxisValueFormatter : NSObject <AxisValueFormatter>
@property (nonatomic, strong) NSArray<FMFundHistoryData *> *historyData;
@property (nonatomic, assign) NSInteger labelCount;
@end

@implementation FMDateAxisValueFormatter

- (NSString *)stringForValue:(double)value axis:(AxisBase *)axis {
    NSInteger index = (NSInteger)round(value);

    // 检查索引范围
    if (index < 0 || index >= self.historyData.count) {
        return @"";
    }

    // 计算是否应该显示标签
    NSInteger dataCount = self.historyData.count;
    double interval = (double)(dataCount - 1) / (double)(self.labelCount - 1);

    // 检查当前索引是否接近某个标签位置
    for (NSInteger i = 0; i < self.labelCount; i++) {
        NSInteger targetIndex = (NSInteger)round(i * interval);
        if (abs(index - targetIndex) < 1) {
            // 返回日期标签
            FMFundHistoryData *data = self.historyData[index];
            NSArray *components = [data.date componentsSeparatedByString:@"-"];
            if (components.count >= 3) {
                return [NSString stringWithFormat:@"%@-%@",
                    components[1], components[2]];
            }
        }
    }

    return @"";
}

@end
```

## 调试技巧

### 1. 打印 entries 数组

```objc
NSLog(@"X轴 entries: %@", xAxis.entries);
// 输出：X轴 entries: (0, 4.83, 9.66, 14.5, 19.33, 24.16, 29)
```

### 2. 打印标签数组

```objc
NSLog(@"标签数组长度: %lu", (unsigned long)labels.count);
for (NSInteger i = 0; i < labels.count; i++) {
    if (labels[i].length > 0) {
        NSLog(@"位置 %ld: %@", (long)i, labels[i]);
    }
}
```

### 3. 在 valueFormatter 中打印

```objc
- (NSString *)stringForValue:(double)value axis:(AxisBase *)axis {
    NSLog(@"请求标签，value: %.2f", value);
    // ... 返回标签
}
```

## 常见问题

### Q1: 为什么只显示2个标签？

**可能原因**：
1. `labelCount` 设置太小
2. `granularity` 设置太大，导致标签被跳过
3. 标签数组大小不匹配数据点数量
4. `valueFormatter` 返回空字符串

**解决方法**：
- 设置 `xAxis.forceLabelsEnabled = YES`
- 禁用 `granularityEnabled`
- 确保标签数组大小 = 数据点数量

### Q2: 标签位置不均匀？

**原因**：DGCharts 的 `computeAxisValues` 会自动调整间隔

**解决方法**：
- 使用 `forceLabelsEnabled = YES`
- 或使用自定义格式化器动态计算

### Q3: 标签显示不全？

**可能原因**：
1. 标签太长，超出图表边界
2. `avoidFirstLastClippingEnabled` 导致首尾标签被调整

**解决方法**：
```objc
xAxis.avoidFirstLastClippingEnabled = NO;
xAxis.labelRotationAngle = 45;  // 旋转标签
```

## 总结

DGCharts 的时间轴绘制流程：
1. **计算轴值**：根据 `labelCount` 和数据范围计算 `entries`
2. **格式化标签**：对每个 entry 调用 `valueFormatter.stringForValue()`
3. **绘制标签**：在计算出的位置绘制格式化后的文本

我们的实现：
- 创建与数据点数量相同的标签数组
- 只在特定位置填充日期，其他位置为空
- DGCharts 会跳过空字符串，只显示有内容的标签

---

**文档创建时间**：2026-02-04
**DGCharts 版本**：5.1.0
