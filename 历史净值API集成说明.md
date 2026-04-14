# 基金历史净值真实数据集成说明

## 功能概述

将基金详情页面的历史净值数据从模拟数据改为调用天天基金（东方财富）的真实 API 接口。

## API 信息

### 天天基金历史净值接口

**接口地址**：`http://api.fund.eastmoney.com/f10/lsjz`

**请求方式**：GET

**请求参数**：
- `callback`: JSONP 回调函数名（如：jQuery）
- `fundCode`: 基金代码（必填）
- `pageIndex`: 页码，从 1 开始（默认：1）
- `pageSize`: 每页数量（默认：20）
- `startDate`: 开始日期（可选，格式：YYYY-MM-DD）
- `endDate`: 结束日期（可选，格式：YYYY-MM-DD）

**示例请求**：
```
http://api.fund.eastmoney.com/f10/lsjz?callback=jQuery&fundCode=000001&pageIndex=1&pageSize=30&startDate=&endDate=
```

## 已实现功能

### 1. FMNetworkManager.h
```objc
// 获取基金历史净值数据
- (void)fetchFundHistoryData:(NSString *)fundCode
                    pageSize:(NSInteger)pageSize
                     success:(FMNetworkSuccessBlock)success
                     failure:(FMNetworkFailureBlock)failure;
```

### 2. FMNetworkManager.m
- `fetchFundHistoryData:failure:` - 获取历史净值数据
- `parseHistoryDataFromJSONP:` - 解析 JSONP 数据

### 3. FMFundDetailViewController.m
- 使用真实 API 获取历史净值数据
- 支持时间段选择（近1月/3月/6月/1年/3年）

## 数据流程

```
用户进入基金详情页
    ↓
显示基本信息（使用缓存数据）
    ↓
请求历史净值接口（30天数据）
    ↓
解析 JSONP 数据
    ↓
更新图表和表格
```

---

**修改完成时间**：2026-02
**修改类型**：功能增强 - 集成真实历史净值 API
**API 来源**：天天基金（东方财富）
