# Fund Monitor 项目结构

## 模块化组织

### MyFunds（自选模块）
- Controllers/
  - FMMyFundsViewController - 自选基金列表页
  - FMAddFundViewController - 添加基金页
  - FMGroupManageViewController - 分组管理页
- Views/
  - FMAssetCardView - 资产卡片视图
  - FMListHeaderView - 列表头部视图
  - FMFundCell - 基金单元格
- Models/
  - FMGroup - 分组模型

### HotFunds（热门模块）
- Controllers/
  - FMHotFundsViewController - 热门基金列表页
- Views/
  - (共享 FMFundCell)

### Settings（设置模块）
- Controllers/
  - FMSettingsViewController - 设置主页
  - FMAboutViewController - 关于页面
  - FMRefreshIntervalViewController - 刷新频率页面

### Common（公共模块）
- Controllers/
  - FMMainTabBarController - 主TabBar控制器
  - FMFundDetailViewController - 基金详情页（共享）
- Views/
  - FMFunctionBarView - 功能栏视图（如果使用）
- Models/
  - FMFund - 基金模型
- Managers/
  - FMDataManager - 数据管理器
  - FMNetworkManager - 网络管理器
  - FMSettingsManager - 设置管理器

## 文件移动计划

### 自选模块
mv Controllers/FMMyFundsViewController.* MyFunds/Controllers/
mv Controllers/FMAddFundViewController.* MyFunds/Controllers/
mv Controllers/FMGroupManageViewController.* MyFunds/Controllers/
mv Views/FMAssetCardView.* MyFunds/Views/
mv Views/FMListHeaderView.* MyFunds/Views/
mv Views/FMFundCell.* MyFunds/Views/
mv Models/FMGroup.* MyFunds/Models/

### 热门模块
mv Controllers/FMHotFundsViewController.* HotFunds/Controllers/

### 设置模块
mv Controllers/FMSettingsViewController.* Settings/Controllers/
mv Controllers/FMAboutViewController.* Settings/Controllers/
mv Controllers/FMRefreshIntervalViewController.* Settings/Controllers/

### 公共模块
mv Controllers/FMMainTabBarController.* Common/Controllers/
mv Controllers/FMFundDetailViewController.* Common/Controllers/
mv Views/FMFunctionBarView.* Common/Views/
mv Models/FMFund.* Common/Models/
mv Managers/* Common/Managers/
