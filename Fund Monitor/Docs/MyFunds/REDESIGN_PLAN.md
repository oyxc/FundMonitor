# 自选模块重构方案 - 养基宝风格

## 设计目标

参考养基宝App的界面设计，重构自选模块，提供更专业的基金管理体验。

## 界面结构

### 1. 顶部资产卡片区域
```
┌─────────────────────────────────────┐
│ 账户资产 👁                          │
│ 1,180.38                            │
│                    01-30 当日总收益  │
│                    +3.22 →          │
└─────────────────────────────────────┘
```

**功能**：
- 显示账户总资产
- 显示当日总收益（金额和百分比）
- 眼睛图标：隐藏/显示资产
- 点击可查看详细收益

### 2. 功能按钮栏
```
┌─────────────────────────────────────┐
│ ⚙️  📊  🔍  ≡                        │
└─────────────────────────────────────┘
```

**按钮**：
- ⚙️ 设置：基金排序、显示设置
- 📊 列表/卡片切换
- 🔍 搜索基金
- ≡ 排序方式

### 3. 列表头部
```
┌─────────────────────────────────────┐
│ 基金名称    估算净值↓  最新净值↓  持有收益↓│
│            01-30     01-30     01-30  │
└─────────────────────────────────────┘
```

**功能**：
- 可点击排序
- 显示日期
- 箭头指示排序方向

### 4. 基金列表项
```
┌─────────────────────────────────────┐
│ 永赢高端装备智选混...  -1.75%  -1.44%  +51.76│
│ ¥ 151.76              1.5668  1.5717  +51.76%│
├─────────────────────────────────────┤
│ 永赢先锋半导体智选...  +0.02%  +1.29%  +25.82│
│ ¥ 125.82              1.7712  1.7936  +25.82%│
└─────────────────────────────────────┘
```

**显示内容**：
- 第一行：基金名称、估算涨跌幅、最新涨跌幅、持有收益金额
- 第二行：持有金额、估算净值、最新净值、持有收益百分比

### 5. 底部指数栏
```
┌─────────────────────────────────────┐
│ 上证指数  4117.95  -40.03  -0.96% ↗ │
└─────────────────────────────────────┘
```

## 数据结构扩展

需要扩展 FMFund 模型，增加以下字段：

```objective-c
@interface FMFund : NSObject

// 现有字段...

// 新增字段
@property (nonatomic, strong) NSNumber *holdAmount;      // 持有金额
@property (nonatomic, strong) NSNumber *holdProfit;      // 持有收益金额
@property (nonatomic, strong) NSNumber *holdProfitRate;  // 持有收益率
@property (nonatomic, strong) NSNumber *estimateRate;    // 估算涨跌幅
@property (nonatomic, strong) NSNumber *latestRate;      // 最新涨跌幅

@end
```

## 实现步骤

### 第一阶段：数据模型扩展
1. 扩展 FMFund 模型
2. 更新数据管理类
3. 添加持仓计算逻辑

### 第二阶段：UI重构
1. 创建资产卡片视图
2. 创建功能按钮栏
3. 重新设计列表Cell
4. 添加底部指数栏

### 第三阶段：交互优化
1. 实现排序功能
2. 实现资产隐藏/显示
3. 实现列表/卡片切换
4. 添加手势操作

## 新建文件清单

### 视图组件
```
Views/
├── FMAssetCardView.h/m          # 资产卡片视图
├── FMFunctionBarView.h/m        # 功能按钮栏
├── FMFundListCell.h/m           # 新的基金列表Cell
├── FMIndexBarView.h/m           # 底部指数栏
└── FMListHeaderView.h/m         # 列表头部视图
```

### 控制器
```
Controllers/
└── FMMyFundsViewController.m    # 重构现有控制器
```

### 工具类
```
Utils/
├── FMCalculator.h/m             # 收益计算工具
└── FMFormatter.h/m              # 数据格式化工具
```

## 详细设计

### 1. 资产卡片视图 (FMAssetCardView)

```objective-c
@interface FMAssetCardView : UIView

@property (nonatomic, assign) double totalAsset;        // 总资产
@property (nonatomic, assign) double todayProfit;       // 当日收益
@property (nonatomic, assign) double todayProfitRate;   // 当日收益率
@property (nonatomic, assign) BOOL assetHidden;         // 是否隐藏资产

- (void)updateAssetData;

@end
```

**布局**：
- 高度：100pt
- 背景：白色卡片，圆角8pt，阴影
- 左侧：账户资产标题 + 金额
- 右侧：当日收益标题 + 金额 + 百分比

### 2. 功能按钮栏 (FMFunctionBarView)

```objective-c
@interface FMFunctionBarView : UIView

@property (nonatomic, copy) void(^onSettingsTapped)(void);
@property (nonatomic, copy) void(^onViewModeTapped)(void);
@property (nonatomic, copy) void(^onSearchTapped)(void);
@property (nonatomic, copy) void(^onSortTapped)(void);

@end
```

**布局**：
- 高度：44pt
- 4个按钮均匀分布
- 图标大小：24x24pt

### 3. 基金列表Cell (FMFundListCell)

```objective-c
@interface FMFundListCell : UITableViewCell

@property (nonatomic, strong) FMFund *fund;

@end
```

**布局**：
- 高度：60pt
- 4列布局：
  - 列1：基金名称 + 持有金额（左对齐，宽度40%）
  - 列2：估算净值 + 估算涨跌幅（居中，宽度20%）
  - 列3：最新净值 + 最新涨跌幅（居中，宽度20%）
  - 列4：持有收益 + 收益率（右对齐，宽度20%）

### 4. 列表头部视图 (FMListHeaderView)

```objective-c
@interface FMListHeaderView : UIView

typedef NS_ENUM(NSInteger, FMSortType) {
    FMSortTypeNone,
    FMSortTypeEstimate,
    FMSortTypeLatest,
    FMSortTypeProfit
};

@property (nonatomic, assign) FMSortType sortType;
@property (nonatomic, assign) BOOL ascending;
@property (nonatomic, copy) void(^onSortChanged)(FMSortType type);

@end
```

**布局**：
- 高度：60pt
- 第一行：列标题（可点击排序）
- 第二行：日期显示

### 5. 底部指数栏 (FMIndexBarView)

```objective-c
@interface FMIndexBarView : UIView

@property (nonatomic, copy) NSString *indexName;
@property (nonatomic, assign) double indexValue;
@property (nonatomic, assign) double indexChange;
@property (nonatomic, assign) double indexChangeRate;

- (void)updateIndexData;

@end
```

**布局**：
- 高度：40pt
- 背景：浅灰色
- 显示：指数名称 + 当前值 + 涨跌额 + 涨跌幅 + 趋势图标

## 颜色规范

```objective-c
// 涨跌颜色
#define COLOR_RISE   [UIColor colorWithRed:0.9 green:0.2 blue:0.2 alpha:1.0]  // 红色
#define COLOR_FALL   [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0]  // 绿色
#define COLOR_FLAT   [UIColor grayColor]                                       // 灰色

// 背景颜色
#define COLOR_BG     [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0]
#define COLOR_CARD   [UIColor whiteColor]

// 文字颜色
#define COLOR_TEXT_PRIMARY    [UIColor blackColor]
#define COLOR_TEXT_SECONDARY  [UIColor grayColor]
#define COLOR_TEXT_LIGHT      [UIColor lightGrayColor]
```

## 字体规范

```objective-c
// 标题
#define FONT_TITLE       [UIFont boldSystemFontOfSize:16]
#define FONT_SUBTITLE    [UIFont systemFontOfSize:14]

// 数值
#define FONT_NUMBER_LARGE  [UIFont boldSystemFontOfSize:24]
#define FONT_NUMBER_MEDIUM [UIFont boldSystemFontOfSize:16]
#define FONT_NUMBER_SMALL  [UIFont systemFontOfSize:14]

// 说明文字
#define FONT_CAPTION     [UIFont systemFontOfSize:12]
```

## 排序功能

支持以下排序方式：
1. 默认排序（添加时间）
2. 估算涨跌幅排序
3. 最新涨跌幅排序
4. 持有收益排序

每种排序支持升序/降序切换。

## 数据计算

### 总资产计算
```objective-c
总资产 = Σ(每只基金的持有金额)
```

### 当日收益计算
```objective-c
当日收益 = Σ(每只基金的持有金额 × 当日涨跌幅)
当日收益率 = 当日收益 / (总资产 - 当日收益) × 100%
```

### 持有收益计算
```objective-c
持有收益 = 持有金额 - 成本金额
持有收益率 = 持有收益 / 成本金额 × 100%
```

## 实现状态

### P0 - 核心功能（已完成）
- [x] 基金列表显示
- [x] 资产卡片显示
- [x] 4列数据布局
- [x] 涨跌颜色显示
- [x] 下拉刷新

### P1 - 重要功能（已完成）
- [x] 排序功能
- [x] 资产隐藏/显示（眼睛按钮）
- [x] 持仓数据管理
- [ ] 底部指数栏

### P2 - 优化功能
- [ ] 列表/卡片切换
- [x] 搜索功能（已完成）
- [x] 手势操作（滑动删除已完成）
- [x] 动画效果

## 注意事项

1. **数据持久化**：持仓数据需要本地存储
2. **性能优化**：列表滚动要流畅，使用Cell复用
3. **数据更新**：实时更新估值数据
4. **容错处理**：网络异常、数据缺失的处理
5. **用户体验**：加载状态、空状态的友好提示

## 下一步行动

由于这是一个较大的重构，建议分步实施：

1. **第一步**：创建新的Cell样式，实现4列布局
2. **第二步**：添加资产卡片和功能按钮栏
3. **第三步**：实现排序和数据计算
4. **第四步**：添加底部指数栏和其他优化

是否开始实施第一步？
