//
//  FMTopHoldingsView.m
//  FundMonitor
//
//  基金十大重仓视图
//

#import "FMTopHoldingsView.h"

@interface FMHoldingCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;      // 股票名称
@property (nonatomic, strong) UILabel *codeLabel;      // 股票代码
@property (nonatomic, strong) UILabel *priceLabel;     // 最新价
@property (nonatomic, strong) UILabel *changeLabel;    // 涨跌幅
@property (nonatomic, strong) UILabel *ratioLabel;     // 占净值比例
@end

@implementation FMHoldingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 股票名称
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:13];
        self.nameLabel.textColor = [UIColor labelColor];
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.nameLabel];

        // 股票代码
        self.codeLabel = [[UILabel alloc] init];
        self.codeLabel.font = [UIFont systemFontOfSize:12];
        self.codeLabel.textColor = [UIColor secondaryLabelColor];
        self.codeLabel.textAlignment = NSTextAlignmentLeft;
        self.codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.codeLabel];
        
        // 占净值比例
        self.ratioLabel = [[UILabel alloc] init];
        self.ratioLabel.font = [UIFont systemFontOfSize:13];
        self.ratioLabel.textColor = [UIColor secondaryLabelColor];
        self.ratioLabel.textAlignment = NSTextAlignmentRight;
        self.ratioLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.ratioLabel];

        // 最新价
        self.priceLabel = [[UILabel alloc] init];
        self.priceLabel.font = [UIFont systemFontOfSize:13];
        self.priceLabel.textColor = [UIColor labelColor];
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.priceLabel];

        // 涨跌幅
        self.changeLabel = [[UILabel alloc] init];
        self.changeLabel.font = [UIFont systemFontOfSize:13];
        self.changeLabel.textAlignment = NSTextAlignmentRight;
        self.changeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.changeLabel];

        // 布局
        [NSLayoutConstraint activateConstraints:@[
            // 股票名称
            [self.nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8],
            [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [self.nameLabel.widthAnchor constraintLessThanOrEqualToConstant:120],
            [self.nameLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],

            // 股票代码
            [self.codeLabel.centerYAnchor constraintEqualToAnchor:self.nameLabel.centerYAnchor],
            [self.codeLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.trailingAnchor constant:10],

            // 占净值比例
            [self.ratioLabel.centerYAnchor constraintEqualToAnchor:self.nameLabel.centerYAnchor],
            [self.ratioLabel.widthAnchor constraintEqualToConstant:70],
            
            // 最新价
            [self.priceLabel.centerYAnchor constraintEqualToAnchor:self.nameLabel.centerYAnchor],
            [self.priceLabel.leadingAnchor constraintEqualToAnchor:self.ratioLabel.trailingAnchor],
            [self.priceLabel.widthAnchor constraintEqualToAnchor:self.ratioLabel.widthAnchor],

            // 涨跌幅
            [self.changeLabel.centerYAnchor constraintEqualToAnchor:self.nameLabel.centerYAnchor],
            [self.changeLabel.leadingAnchor constraintEqualToAnchor:self.priceLabel.trailingAnchor],
            [self.changeLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],
            [self.changeLabel.widthAnchor constraintEqualToAnchor:self.ratioLabel.widthAnchor],
        ]];
    }
    return self;
}

@end

@interface FMTopHoldingsView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *reportDateLabel;
@property (nonatomic, strong) UILabel *codeLabel;       // 股票 (代码)
@property (nonatomic, strong) UILabel *leveLabel;       // 占比
@property (nonatomic, strong) UILabel *priceLabel;      // 股价
@property (nonatomic, strong) UILabel *dayRateLabel;    // 日涨幅
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *holdings;  // 持仓数据（包含行情）
@property (nonatomic, copy) NSString *reportDate;  // 报告日期
@property (nonatomic, copy) NSString *stockCodes;  // 股票代码列表（用于查询行情）

@end

@implementation FMTopHoldingsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    self.layer.cornerRadius = 10;
    self.clipsToBounds = YES;

    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"十大重仓股票";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleLabel];

    // 报告日期
    self.reportDateLabel = [[UILabel alloc] init];
    self.reportDateLabel.font = [UIFont systemFontOfSize:12];
    self.reportDateLabel.textColor = [UIColor secondaryLabelColor];
    self.reportDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.reportDateLabel];
    
    
    // 股票 (代码)
    self.codeLabel = [[UILabel alloc] init];
    self.codeLabel.text = @"股票 (代码)";
    self.codeLabel.font = [UIFont systemFontOfSize:13];
    self.codeLabel.textColor = [UIColor secondaryLabelColor];
    self.codeLabel.textAlignment = NSTextAlignmentLeft;
    self.codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.codeLabel];
    
    // 占比
    self.leveLabel = [[UILabel alloc] init];
    self.leveLabel.text = @"占比";
    self.leveLabel.font = [UIFont systemFontOfSize:13];
    self.leveLabel.textColor = [UIColor secondaryLabelColor];
    self.leveLabel.textAlignment = NSTextAlignmentRight;
    self.leveLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.leveLabel];
    
    // 股价
    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.text = @"股价";
    self.priceLabel.font = [UIFont systemFontOfSize:13];
    self.priceLabel.textColor = [UIColor secondaryLabelColor];
    self.priceLabel.textAlignment = NSTextAlignmentRight;
    self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.priceLabel];
    
    // 日涨幅
    self.dayRateLabel = [[UILabel alloc] init];
    self.dayRateLabel.text = @"日涨幅";
    self.dayRateLabel.font = [UIFont systemFontOfSize:13];
    self.dayRateLabel.textColor = [UIColor secondaryLabelColor];
    self.dayRateLabel.textAlignment = NSTextAlignmentRight;
    self.dayRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.dayRateLabel];

    // 表格
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.scrollEnabled = NO;
    self.tableView.rowHeight = 50;  // 增加行高以容纳更多信息
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[FMHoldingCell class] forCellReuseIdentifier:@"HoldingCell"];
    [self addSubview:self.tableView];

    // 加载指示器
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.loadingView];

    // 布局
    [NSLayoutConstraint activateConstraints:@[
        // 标题
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],

        // 报告日期
        [self.reportDateLabel.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor],
        [self.reportDateLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        
        // 股票 (代码)
        [self.codeLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        [self.codeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        
        // 占比
        [self.leveLabel.topAnchor constraintEqualToAnchor:self.codeLabel.topAnchor],
        [self.leveLabel.widthAnchor constraintEqualToConstant:70],
        
        // 股价
        [self.priceLabel.topAnchor constraintEqualToAnchor:self.codeLabel.topAnchor],
        [self.priceLabel.leadingAnchor constraintEqualToAnchor:self.leveLabel.trailingAnchor constant:0],
        [self.priceLabel.widthAnchor constraintEqualToAnchor:self.leveLabel.widthAnchor],
        
        // 日涨幅
        [self.dayRateLabel.topAnchor constraintEqualToAnchor:self.codeLabel.topAnchor],
        [self.dayRateLabel.leadingAnchor constraintEqualToAnchor:self.priceLabel.trailingAnchor constant:0],
        [self.dayRateLabel.widthAnchor constraintEqualToAnchor:self.leveLabel.widthAnchor],
        [self.dayRateLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],

        // 表格
        [self.tableView.topAnchor constraintEqualToAnchor:self.codeLabel.bottomAnchor constant:10],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.tableView.heightAnchor constraintEqualToConstant:500],  // 10行 * 50
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-16],

        // 加载指示器
        [self.loadingView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.loadingView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
    ]];
}

- (void)loadHoldingsData {

    if (!self.fundCode || self.fundCode.length == 0) {
        return;
    }

    [self.loadingView startAnimating];
    self.tableView.hidden = YES;

    // 步骤1: 获取基金持仓数据
    NSString *urlString = [NSString stringWithFormat:
        @"http://fundf10.eastmoney.com/FundArchivesDatas.aspx?type=jjcc&code=%@&topline=16&rt=%.0f",
        self.fundCode, [[NSDate date] timeIntervalSince1970] * 1000];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSLog(@"loadHoldingsData 加载开始 %.0f", NSDate.date.timeIntervalSince1970);
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.loadingView stopAnimating];
                NSLog(@"❌ 获取持仓数据失败: %@", error);
            });
            return;
        }

        NSLog(@"loadHoldingsData 解析数据 %.0f", NSDate.date.timeIntervalSince1970);
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [weakSelf parseHoldingsData:responseString];

        // 步骤2: 获取股票实时行情
        if (weakSelf.stockCodes && weakSelf.stockCodes.length > 0) {
            [weakSelf loadStockQuotes];
        }
        NSLog(@"loadHoldingsData 加载完成 %.0f", NSDate.date.timeIntervalSince1970);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingView stopAnimating];
            weakSelf.tableView.hidden = NO;
            [weakSelf.tableView reloadData];
        });
    }];

    [task resume];
}

// 使用 stockCodesNew 初始化持仓数据
- (void)initHoldingsWithStockCodes:(NSArray<NSString *> *)stockCodes {
    self.holdings = [NSMutableArray array];

    for (NSInteger i = 0; i < stockCodes.count; i++) {
        NSString *codeWithPrefix = stockCodes[i];
        // 去掉前缀获取纯股票代码
        NSString *stockCode = @"";
        NSArray *parts = [codeWithPrefix componentsSeparatedByString:@"."];
        if (parts.count >= 2) {
            stockCode = parts[1];
        } else {
            stockCode = codeWithPrefix;
        }

        NSMutableDictionary *holding = [NSMutableDictionary dictionaryWithDictionary:@{
            @"seq": [NSString stringWithFormat:@"%ld", (long)(i + 1)],
            @"code": stockCode,
            @"name": @"--",      // 待从行情API获取
            @"ratio": @"--",     // 待获取
            @"price": @"--",    // 待填充
            @"change": @"--",   // 待填充
            @"changeValue": @(0)
        }];

        [self.holdings addObject:holding];
    }
}

// 使用 stockCodesNew 的行情数据更新持仓
- (void)updateHoldingsWithQuotesFromStockCodesNew:(NSArray *)quotes {
    // 创建股票代码到行情的映射（去掉前缀）
    NSMutableDictionary *quoteMap = [NSMutableDictionary dictionary];
    for (NSDictionary *quote in quotes) {
        NSString *fullCode = quote[@"f12"];  // 完整代码如 688213
        if (fullCode) {
            quoteMap[fullCode] = quote;
        }
    }

    // 更新持仓数据
    for (NSMutableDictionary *holding in self.holdings) {
        NSString *code = holding[@"code"];
        NSDictionary *quote = quoteMap[code];

        if (quote) {
            // f14: 股票名称, f2: 最新价, f3: 涨跌幅(%)
            NSString *name = quote[@"f14"];
            NSNumber *price = quote[@"f2"];
            NSNumber *changePercent = quote[@"f3"];

            if (name) {
                holding[@"name"] = name;
            }

            if (price) {
                holding[@"price"] = [NSString stringWithFormat:@"%.2f", [price doubleValue]];
            }

            if (changePercent) {
                double change = [changePercent doubleValue];
                holding[@"changeValue"] = @(change);

                if (change > 0) {
                    holding[@"change"] = [NSString stringWithFormat:@"+%.2f%%", change];
                } else {
                    holding[@"change"] = [NSString stringWithFormat:@"%.2f%%", change];
                }
            }
        }
    }
}

- (void)parseHoldingsData:(NSString *)htmlString {
    self.holdings = [NSMutableArray array];
    
    NSError *error;
    NSRegularExpression *regexBox = [NSRegularExpression regularExpressionWithPattern:@"<div class='box'>"
                                                                           options:0
                                                                             error:&error];
    NSArray *boxMatches = [regexBox matchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length)];
    if (boxMatches.count > 1) {
        NSTextCheckingResult *match = boxMatches[1];
        htmlString = [htmlString substringToIndex:match.range.location];
    }
    
    // 提取报告日期
    NSRegularExpression *dateRegex = [NSRegularExpression regularExpressionWithPattern:
        @"截止至：<font class=.*?>(\\d{4}-\\d{2}-\\d{2})</font>" options:0 error:nil];
    NSTextCheckingResult *dateMatch = [dateRegex firstMatchInString:htmlString options:0 range:NSMakeRange(0, htmlString.length)];
    if (dateMatch && dateMatch.numberOfRanges > 1) {
        self.reportDate = [htmlString substringWithRange:[dateMatch rangeAtIndex:1]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.reportDateLabel.text = [NSString stringWithFormat:@"截止 %@", self.reportDate];
        });
    }

    // 提取股票代码列表（从 gpdmList 中）
    NSRegularExpression *codesRegex = [NSRegularExpression regularExpressionWithPattern:
        @"<div class='hide' id='gpdmList'>([^<]+)</div>" options:0 error:nil];
    NSTextCheckingResult *codesMatch = [codesRegex firstMatchInString:htmlString options:0 range:NSMakeRange(0, htmlString.length)];
    if (codesMatch && codesMatch.numberOfRanges > 1) {
        self.stockCodes = [htmlString substringWithRange:[codesMatch rangeAtIndex:1]];
    }

    // 提取持仓数据（最新季度包含最新价和涨跌幅的占位符）
    NSString *pattern = @"<tr><td>(\\d+)</td><td.*?><a href=.*?>(.*?)</a></td><td class=.*?><a href=.*?>(.*?)</a></td><td class=.*?</a></td><td class=.*?>([\\d.]+%)</td>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray *matches = [regex matchesInString:htmlString options:0 range:NSMakeRange(0, htmlString.length)];

    for (NSTextCheckingResult *match in matches) {
        if (match.numberOfRanges >= 5) {
            NSString *seq = [htmlString substringWithRange:[match rangeAtIndex:1]];
            NSString *code = [htmlString substringWithRange:[match rangeAtIndex:2]];
            NSString *name = [htmlString substringWithRange:[match rangeAtIndex:3]];
            NSString *ratio = [htmlString substringWithRange:[match rangeAtIndex:4]];

            NSMutableDictionary *holding = [NSMutableDictionary dictionaryWithDictionary:@{
                @"seq": seq,
                @"code": code,
                @"name": name,
                @"ratio": ratio,
                @"price": @"--",      // 待填充
                @"change": @"--",     // 待填充
                @"changeValue": @(0)  // 用于颜色判断
            }];

            [self.holdings addObject:holding];
        }
    }
}

// 加载股票实时行情
- (void)loadStockQuotes {
    if (!self.stockCodes || self.stockCodes.length == 0) {
        return;
    }

    // 移除末尾的逗号
    NSString *codes = [self.stockCodes stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];

    NSString *urlString = [NSString stringWithFormat:
        @"http://push2.eastmoney.com/api/qt/ulist.np/get?fltt=2&secids=%@&fields=f12,f14,f2,f3,f4",
        codes];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingView stopAnimating];

            if (error) {
                NSLog(@"❌ 获取股票行情失败: %@", error);
                weakSelf.tableView.hidden = NO;
                [weakSelf.tableView reloadData];
                return;
            }

            // 解析JSON数据
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"❌ 解析行情数据失败: %@", jsonError);
                weakSelf.tableView.hidden = NO;
                [weakSelf.tableView reloadData];
                return;
            }

            // 提取股票行情数据
            NSArray *quotes = json[@"data"][@"diff"];
            if (quotes && [quotes isKindOfClass:[NSArray class]]) {
                [weakSelf updateHoldingsWithQuotes:quotes];
            }

            weakSelf.tableView.hidden = NO;
            [weakSelf.tableView reloadData];
            NSLog(@"loadHoldingsData 加载详情完成 %.0f", NSDate.date.timeIntervalSince1970);
        });
    }];

    [task resume];
}

// 更新持仓数据（合并行情信息）
- (void)updateHoldingsWithQuotes:(NSArray *)quotes {
    // 创建股票代码到行情的映射
    NSMutableDictionary *quoteMap = [NSMutableDictionary dictionary];
    for (NSDictionary *quote in quotes) {
        NSString *code = quote[@"f12"];
        if (code) {
            quoteMap[code] = quote;
        }
    }

    // 更新持仓数据
    for (NSMutableDictionary *holding in self.holdings) {
        NSString *code = holding[@"code"];
        NSDictionary *quote = quoteMap[code];

        if (quote) {
            // f2: 最新价, f3: 涨跌幅(%), f4: 涨跌额
            NSNumber *price = quote[@"f2"];
            NSNumber *changePercent = quote[@"f3"];

            if (price) {
                holding[@"price"] = [NSString stringWithFormat:@"%.2f", [price doubleValue]];
            }

            if (changePercent) {
                double change = [changePercent doubleValue];
                holding[@"changeValue"] = @(change);

                if (change > 0) {
                    holding[@"change"] = [NSString stringWithFormat:@"+%.2f%%", change];
                } else {
                    holding[@"change"] = [NSString stringWithFormat:@"%.2f%%", change];
                }
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.holdings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMHoldingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HoldingCell" forIndexPath:indexPath];

    NSDictionary *holding = self.holdings[indexPath.row];
    NSString *seq = holding[@"seq"];
    NSString *code = holding[@"code"];
    NSString *name = holding[@"name"];
    NSString *price = holding[@"price"];
    NSString *change = holding[@"change"];
    NSString *ratio = holding[@"ratio"];
    NSNumber *changeValue = holding[@"changeValue"];

    // 设置数据
    cell.nameLabel.text = [NSString stringWithFormat:@"%@. %@", seq, name];
    cell.codeLabel.text = [NSString stringWithFormat:@"(%@)", code];
    cell.priceLabel.text = price;
    cell.changeLabel.text = change;
    cell.ratioLabel.text = ratio;

    // 设置涨跌幅颜色
    double changeVal = [changeValue doubleValue];
    if (changeVal > 0) {
        cell.changeLabel.textColor = [UIColor systemRedColor];
    } else if (changeVal < 0) {
        cell.changeLabel.textColor = [UIColor systemGreenColor];
    } else {
        cell.changeLabel.textColor = [UIColor secondaryLabelColor];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

@end
