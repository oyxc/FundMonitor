# Fund Monitor 项目结构说明

## 📁 目录结构

```
Fund Monitor/
├── MyFunds/                    # 自选模块
│   ├── Controllers/
│   │   ├── FMMyFundsViewController      - 自选基金列表主页
│   │   ├── FMAddFundViewController      - 添加基金（搜索）
│   │   └── FMGroupManageViewController  - 分组管理
│   ├── Views/
│   │   ├── FMAssetCardView             - 资产卡片（总资产+收益）
│   │   ├── FMListHeaderView            - 列表头部（排序按钮）
│   │   └── FMFundCell                  - 基金列表单元格
│   └── Models/
│       └── FMGroup                     - 分组数据模型
│
├── HotFunds/                   # 热门模块
│   └── Controllers/
│       └── FMHotFundsViewController    - 热门基金列表页
│
├── Companies/                  # 基金公司模块
│   └── Controllers/
│       └── FMFundCompaniesViewController - 基金公司列表页
│
├── Settings/                   # 设置模块
│   └── Controllers/
│       ├── FMSettingsViewController         - 设置主页
│       ├── FMAboutViewController            - 关于页面
│       └── FMRefreshIntervalViewController  - 刷新频率设置
│
└── Common/                     # 公共模块
    ├── Controllers/
    │   ├── FMMainTabBarController         - 主TabBar控制器
    │   ├── FMFundDetailViewController     - 基金详情页
    │   └── FMImportConfirmViewController  - 导入确认页
    ├── Views/
    │   ├── FMFundDetailHeaderView         - 详情页头部视图
    │   ├── FMFundChartView                - 图表视图
    │   ├── FMHistoryDataTableView         - 历史数据表格
    │   ├── FMGroupSelectionView           - 底部分组选择弹窗
    │   └── FMTopHoldingsView              - 十大重仓股票视图
    ├── Models/
    │   ├── FMFund                         - 基金数据模型
    │   ├── FMFundCompany                  - 基金公司模型
    │   ├── FMFundHistoryData              - 历史净值数据
    │   ├── FMNetWorthTrendData           - 净值走势数据
    │   └── FMGrandTotalData               - 累计收益数据
    └── Managers/
        ├── FMDataManager                  - 数据管理（本地存储）
        ├── FMNetworkManager               - 网络请求管理
        └── FMSettingsManager              - 设置管理
```

## 🎯 模块说明

### 1. MyFunds（自选模块）

**功能**：管理用户自选的基金

**页面流程**：
```
FMMyFundsViewController（自选列表）
    ├─→ FMAddFundViewController（添加基金）
    ├─→ FMGroupManageViewController（分组管理）
    ├─→ FMImportConfirmViewController（导入确认）
    └─→ FMFundDetailViewController（基金详情）
```

### 2. HotFunds（热门模块）

**功能**：展示热门基金列表

**页面流程**：
```
FMHotFundsViewController（热门列表）
    └─→ FMFundDetailViewController（基金详情）
```

### 3. Companies（基金公司模块）

**功能**：展示基金公司列表

**页面流程**：
```
FMFundCompaniesViewController（基金公司列表）
    └─→ (待实现) 基金公司详情页
```

### 4. Settings（设置模块）

**功能**：应用设置和信息

## 🔄 模块依赖关系

```
┌─────────────────────────────────────────┐
│         FMMainTabBarController          │
│              (Common)                   │
└────────┬──────────┬──────────┬──────────┘
         │          │          │
    ┌────▼───┐ ┌───▼────┐ ┌───▼────┐
    │MyFunds │ │HotFunds│ │Companies│
    └────┬───┘ └───┬────┘ └──┬──────┘
         │         │          │
         └─────────┴──────────┘
                   │
         ┌─────────▼─────────┐
         │  Common/Managers  │
         │  Common/Models    │
         └───────────────────┘
```

## 📱 页面导航

### Tab 导航
```
TabBar
├─ Tab 1: 自选（star）
├─ Tab 2: 热门（flame）
├─ Tab 3: 基金（building.2）
└─ Tab 4: 设置（gearshape）
```

## 🚀 功能特性

### 自选模块
- ✅ 多分组管理
- ✅ 资产统计（带眼睛按钮隐藏/显示）
- ✅ 自动刷新（1s/2s/3s可配置）
- ✅ 多维度排序
- ✅ 基金搜索添加
- ✅ 导入确认页面
- ✅ 滑动删除基金

### 热门模块
- ✅ 热门基金列表
- ✅ 下拉刷新
- ✅ 分页加载

### 基金公司模块
- ✅ 基金公司列表
- ✅ 搜索功能
- ⏳ 基金公司详情页

### 设置模块
- ✅ 主题切换（跟随系统/强制浅色）
- ✅ 刷新频率配置
- ✅ 应用信息展示

### 公共功能
- ✅ 基金详情查看（三个标签页）
- ✅ 实时估值更新
- ✅ 历史净值数据展示
- ✅ 时间段选择（近1月/3月/6月/1年/3年）
- ✅ 十大重仓股票展示
- ✅ 数据本地缓存
- ✅ 深色模式适配
- ✅ 眼睛按钮状态保存

---

**最后更新**：2026-02
**项目版本**：1.0
