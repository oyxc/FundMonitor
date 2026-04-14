# FundMonitor API 接入说明

## 已接入的真实API

### 1. 基金搜索API

**接口地址**: `https://fundsuggest.eastmoney.com/FundSearch/api/FundSearchAPI.ashx`

**请求方式**: GET

**请求参数**:
- `m`: 固定值 1
- `key`: 搜索关键词（基金代码或名称）

**返回格式**: JSONP

**返回示例**:
```javascript
var suggestionData = {
    "Datas": [
        "001186,富国文体健康股票,股票型,FGWT",
        "110022,易方达消费行业股票,股票型,YFXF"
    ]
}
```

**数据格式**: 每条数据用逗号分隔，包含：
1. 基金代码
2. 基金名称
3. 基金类型
4. 拼音缩写

### 2. 基金实时估值API

**接口地址**: `http://fundgz.1234567.com.cn/js/{fundCode}.js`

**请求方式**: GET

**URL参数**:
- `{fundCode}`: 基金代码，如 001186

**返回格式**: JSONP

**返回示例**:
```javascript
jsonpgz({
    "fundcode": "001186",
    "name": "富国文体健康股票",
    "jzrq": "2024-01-01",
    "dwjz": "1.2100",
    "gsz": "1.2340",
    "gszzl": "1.98",
    "gztime": "2024-01-01 15:00"
});
```

**字段说明**:
- `fundcode`: 基金代码
- `name`: 基金名称
- `jzrq`: 净值日期
- `dwjz`: 昨日净值（单位净值）
- `gsz`: 估算净值
- `gszzl`: 估算涨跌幅（百分比）
- `gztime`: 估值更新时间

### 3. 热门基金列表

**实现方式**: 预设热门基金代码列表，批量调用实时估值API

**热门基金代码**:
```objective-c
@[
    @"001186", // 富国文体健康股票
    @"110022", // 易方达消费行业股票
    @"161725", // 招商中证白酒指数
    @"320007", // 诺安成长混合
    @"163406", // 兴全合润混合
    @"000961", // 天弘沪深300ETF联接A
    @"519674", // 银河创新成长混合
    @"001102", // 前海开源国家比较优势
    @"260108", // 景顺长城新兴成长混合
    @"000751"  // 嘉实新兴产业股票
]
```

## 数据更新频率

- **交易日**: 9:30-15:00 每分钟更新一次
- **非交易时间**: 显示上一交易日收盘数据
- **周末和节假日**: 显示上一交易日收盘数据

## 网络配置

### Info.plist 配置

已在 Info.plist 中配置允许 HTTP 请求：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**注意**: 生产环境建议使用更安全的配置，仅允许特定域名的 HTTP 请求。

### 更安全的配置示例

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>fundgz.1234567.com.cn</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## API 调用示例

### 搜索基金

```objective-c
[[FMNetworkManager sharedManager] searchFundWithKeyword:@"消费"
    success:^(id responseObject) {
        NSArray<FMFund *> *funds = responseObject;
        NSLog(@"搜索到 %ld 只基金", funds.count);
    }
    failure:^(NSError *error) {
        NSLog(@"搜索失败: %@", error.localizedDescription);
    }];
```

### 获取基金实时估值

```objective-c
[[FMNetworkManager sharedManager] fetchFundEstimateValue:@"001186"
    success:^(id responseObject) {
        FMFund *fund = responseObject;
        NSLog(@"基金: %@, 估值: %@, 涨跌幅: %@",
              fund.fundName,
              fund.currentValue,
              fund.changeRate);
    }
    failure:^(NSError *error) {
        NSLog(@"获取失败: %@", error.localizedDescription);
    }];
```

### 批量获取估值

```objective-c
NSArray *codes = @[@"001186", @"110022", @"161725"];
[[FMNetworkManager sharedManager] fetchMultipleFundsEstimate:codes
    success:^(id responseObject) {
        NSArray<FMFund *> *funds = responseObject;
        NSLog(@"获取到 %ld 只基金的估值", funds.count);
    }
    failure:^(NSError *error) {
        NSLog(@"批量获取失败: %@", error.localizedDescription);
    }];
```

### 获取热门基金

```objective-c
[[FMNetworkManager sharedManager] fetchHotFunds:^(id responseObject) {
        NSArray<FMFund *> *funds = responseObject;
        NSLog(@"热门基金: %ld 只", funds.count);
    }
    failure:^(NSError *error) {
        NSLog(@"获取热门基金失败: %@", error.localizedDescription);
    }];
```

## 错误处理

### 常见错误

1. **网络连接失败**
   - 检查设备网络连接
   - 检查 Info.plist 配置

2. **数据解析失败**
   - API 返回格式可能变化
   - 检查 JSONP 解析逻辑

3. **基金代码不存在**
   - 返回空数据或错误
   - 提示用户基金不存在

### 错误处理建议

```objective-c
[[FMNetworkManager sharedManager] fetchFundEstimateValue:fundCode
    success:^(id responseObject) {
        if (responseObject) {
            // 处理成功
        } else {
            // 数据为空
            [self showAlertWithMessage:@"未找到该基金"];
        }
    }
    failure:^(NSError *error) {
        // 网络错误
        NSString *message = error.localizedDescription;
        [self showAlertWithMessage:message];
    }];
```

## 性能优化建议

### 1. 缓存策略

- 本地缓存基金基本信息（名称、类型等）
- 估值数据实时获取，不建议长时间缓存
- 热门基金列表可缓存 5-10 分钟

### 2. 批量请求优化

- 使用 `dispatch_group` 并发请求多个基金
- 限制并发数量，避免请求过多
- 建议每次批量请求不超过 20 只基金

### 3. 请求频率控制

- 避免频繁刷新，建议间隔至少 30 秒
- 使用下拉刷新而非自动刷新
- 非交易时间降低刷新频率

## 数据来源说明

- **天天基金网**: 提供基金实时估值数据
- **东方财富网**: 提供基金搜索功能
- 数据仅供参考，实际以基金公司公布为准

## 免责声明

本应用使用的基金数据来自公开API，仅供学习和参考使用。基金投资有风险，请谨慎决策。

## 扩展API建议

如需更完整的基金数据，可以考虑接入：

1. **基金详情API**: 获取基金经理、公司、成立时间等
2. **历史净值API**: 获取基金历史净值数据
3. **基金排行API**: 获取各类基金排行榜
4. **基金公告API**: 获取基金公告信息

## 更新日志

- **2024-01-01**: 接入天天基金网实时估值API
- **2024-01-01**: 接入东方财富基金搜索API
- **2024-01-01**: 实现JSONP数据解析
