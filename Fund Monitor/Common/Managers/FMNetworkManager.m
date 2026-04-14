//
//  FMNetworkManager.m
//  FundMonitor
//

#import "FMNetworkManager.h"
#import "FMFundHistoryData.h"
#import "FMFundCompany.h"
#import "FMNetWorthTrendData.h"
#import "FMGrandTotalData.h"
#import "FMFundDetailModel.h"
#import "FMNetWorthModel.h"
#import "FMHotFundModel.h"

@interface FMNetworkManager ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation FMNetworkManager

+ (instancetype)sharedManager {
    static FMNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMNetworkManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 15.0;
        self.session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

// 底层通用请求
- (void)requestWithUrl:(NSString *)urlString
              fundCode:(NSString *)fundCode
               success:(void(^)(NSString *jsonString))success
               failure:(FMNetworkFailureBlock)failure {
    if (!urlString || urlString.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"请求链接无效"}];
            failure(error);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"📡 请求URL: %@", urlString);
        
        if (error) {
            NSLog(@"❌ 网络请求失败: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error);
                }
            });
            return;
        }
        
        if (!data) {
            NSLog(@"❌ 未获取到数据");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    NSError *err = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"未获取到数据"}];
                    failure(err);
                }
            });
            return;
        }
        
        // 解析响应数据
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"✅ 原始响应 %@: %@", fundCode, responseString);
        
        if (!responseString) {
            NSLog(@"❌ 无数据");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    NSError *err = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"无数据"}];
                    failure(err);
                }
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(responseString);
            }
        });
    }];
    
    [task resume];
}

#pragma mark - 网络请求

// 搜索基金
- (void)searchFundWithKeyword:(NSString *)keyword
                      success:(FMNetworkSuccessBlock)success
                      failure:(FMNetworkFailureBlock)failure {
    if (!keyword || keyword.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"搜索关键词不能为空"}];
            failure(error);
        }
        return;
    }
    
    // 使用天天基金网搜索API
    NSString *urlString = [NSString stringWithFormat:@"https://fundsuggest.eastmoney.com/FundSearch/api/FundSearchAPI.ashx?m=1&key=%@", [keyword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [self requestWithUrl:urlString fundCode:keyword success:^(NSString *jsonString) {
        // 解析搜索结果
        NSMutableArray *results = [NSMutableArray array];
        
        // 移除JSONP包装
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"var suggestionData = " withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@";" withString:@""];
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *parseError = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
        
        if (!parseError && [jsonDict isKindOfClass:[NSDictionary class]]) {
            NSArray *datas = jsonDict[@"Datas"];
            if ([datas isKindOfClass:[NSArray class]]) {
                for (id item in datas) {
                    // 判断item类型：可能是字符串或字典
                    if ([item isKindOfClass:[NSString class]]) {
                        // 格式: "基金代码,基金简称,基金类型,拼音缩写"
                        NSString *itemStr = (NSString *)item;
                        NSArray *components = [itemStr componentsSeparatedByString:@","];
                        if (components.count >= 2) {
                            NSString *code = components[0];
                            NSString *name = components[1];
                            NSString *type = components.count >= 3 ? components[2] : @"";
                            
                            FMFund *fund = [FMFund fundWithCode:code name:name];
                            fund.fundType = type;
                            [results addObject:fund];
                        }
                    } else if ([item isKindOfClass:[NSDictionary class]]) {
                        // 字典格式（东方财富API返回格式）
                        NSDictionary *itemDict = (NSDictionary *)item;
                        NSString *code = itemDict[@"CODE"] ?: itemDict[@"code"] ?: itemDict[@"fundcode"];
                        NSString *name = itemDict[@"NAME"] ?: itemDict[@"name"] ?: itemDict[@"fundname"];
                        //NSString *jp = itemDict[@"JP"] ?: itemDict[@"jp"] ?: itemDict[@"fundjp"];
                        
                        // 尝试从多个可能的字段获取基金类型
                        NSString *type = @"";
                        
                        // 优先从 FundBaseInfo 中获取详细类型
                        NSDictionary *baseInfo = itemDict[@"FundBaseInfo"];
                        if ([baseInfo isKindOfClass:[NSDictionary class]]) {
                            type = baseInfo[@"FTYPE"] ?: baseInfo[@"ftype"] ?: @"";
                            
                            // 如果有基金公司和基金经理信息，也一并获取
                            NSString *company = baseInfo[@"JJGS"] ?: baseInfo[@"jjgs"];
                            NSString *manager = baseInfo[@"JJJL"] ?: baseInfo[@"jjjl"];
                            NSString *latestValue = baseInfo[@"DWJZ"] ?: baseInfo[@"dwjz"];
                            
                            if (code && name) {
                                FMFund *fund = [FMFund fundWithCode:code name:name];
                                fund.fundType = type;
                                fund.fundCompany = company;
                                fund.fundManager = manager;
                                fund.latestValue = latestValue;
                                [results addObject:fund];
                            }
                        } else {
                            // 如果没有 FundBaseInfo，使用顶层字段
                            type = itemDict[@"TYPE"] ?: itemDict[@"type"] ?: itemDict[@"fundtype"] ?: @"";
                            
                            if (code && name) {
                                FMFund *fund = [FMFund fundWithCode:code name:name];
                                fund.fundType = type;
                                [results addObject:fund];
                            }
                        }
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(results);
            }
        });
        
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(error);
            }
        });
    }];
}

// 获取基金详细信息
- (void)fetchFundDetail:(NSString *)fundCode
                success:(FMNetworkSuccessBlock)success
                failure:(FMNetworkFailureBlock)failure {

    if (!fundCode || fundCode.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"基金代码不能为空"}];
            failure(error);
        }
        return;
    }
//    stockCodesNew
    // 使用天天基金详情API（新接口）
    NSString *urlString = [NSString stringWithFormat:@"http://fund.eastmoney.com/pingzhongdata/%@.js", fundCode];

    [self requestWithUrl:urlString fundCode:fundCode success:^(NSString *jsonString) {
        // 解析JavaScript数据
        FMFundDetailModel *fund = [self parseFundDetailFromJS:jsonString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fund) {
                if (success) {
                    success(fund);
                }
            } else {
                if (failure) {
                    NSError *err = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"数据解析失败"}];
                    failure(err);
                }
            }
        });
        
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(error);
            }
        });
    }];
}

// 获取基金估算净值
- (void)fetchMultipleFundsEstimate:(NSArray<NSString *> *)fundCodes
                           success:(FMNetworkSuccessBlock)success
                           failure:(FMNetworkFailureBlock)failure {
    // 批量获取基金估值
    NSMutableArray *funds = [NSMutableArray array];

    dispatch_group_t group = dispatch_group_create();
//    NSLog(@"create group time:%@ fundCodes:%@",NSDate.date,fundCodes);

    for (NSString *code in fundCodes) {
        dispatch_group_enter(group);
//        NSLog(@"enter group code:%@",code);
        
        [self fetchDayFundEstimateValue:code success:^(id responseObject) {
            if ([responseObject isKindOfClass:[FMNetWorthModel class]]) {
                [funds addObject:responseObject];
            }
            dispatch_group_leave(group);
//            NSLog(@"leave group code:%@",code);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
//            NSLog(@"leave group code:%@",code);
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        NSLog(@"notify group time:%@ fundCodes:%@",NSDate.date,fundCodes);
        if (success) {
            success(funds);
        }
    });
}

// 天天基金-净值估算API
- (void)fetchDayFundEstimateValue:(NSString *)fundCode
                          success:(FMNetworkSuccessBlock)success
                          failure:(FMNetworkFailureBlock)failure {
    if (!fundCode || fundCode.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"基金代码不能为空"}];
            failure(error);
        }
        return;
    }
    
    // 使用天天基金实时估值API
    NSString *urlString = [NSString stringWithFormat:@"https://fundgz.1234567.com.cn/js/%@.js", fundCode];
    
    [self requestWithUrl:urlString fundCode:fundCode success:^(NSString *jsonString) {
        
        // 数据解析
        // 返回格式示例：jsonpgz({"fundcode":"110022","name":"易方达消费行业股票","jzrq":"2026-02-03","dwjz":"3.3830","gsz":"3.4773","gszzl":"2.79","gztime":"2026-02-04 15:00"});
        
        // 移除 JSONP 包装
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"jsonpgz(" withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@");" withString:@""];
        
        // 解析 JSON 字典
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *parseError = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
        
        __block FMNetWorthModel *netModel = [[FMNetWorthModel alloc] init];
        
        BOOL isDataEnabel = NO;
        if (!parseError && [jsonDict isKindOfClass:[NSDictionary class]]) {
            isDataEnabel = YES;
            // 使用字典解析数据
            netModel.fundCode = jsonDict[@"fundcode"] ?: fundCode;
            netModel.netValueDate = jsonDict[@"jzrq"];              // 净值日期
            netModel.unitNetValue = jsonDict[@"dwjz"];              // 单位净值
            netModel.estimateGrowthRate = [NSString stringWithFormat:@"%@%%", jsonDict[@"gszzl"]]; // 估算增长率
            netModel.estimateNetValue = jsonDict[@"gsz"];           // 估算净值
            netModel.estimateDate = jsonDict[@"gztime"];            // 估值时间
            netModel.estimateTime = jsonDict[@"gztime"];            // 估值时间
            
            // 从估值时间中分离日期和时间
            NSArray *timeComponents = [netModel.estimateTime componentsSeparatedByString:@" "];
            if (timeComponents.count >= 2) {
                netModel.estimateDate = timeComponents[0];
                netModel.estimateTime = timeComponents[1];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        
        // estimateNetValue 没有值，从天天基金-接口获取
        if (netModel.growthRate.doubleValue == 0) {
            [weakSelf fetchFundEstimateValue:fundCode success:^(id  _Nonnull responseObject) {
                FMNetWorthModel *newModel = (FMNetWorthModel *)responseObject;
                if (isDataEnabel == NO) {
                    netModel = newModel;
                } else {
                    netModel.growthRate = newModel.growthRate;
                    NSString *net_netValueDate = [netModel.netValueDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    NSString *new_netValueDate = [newModel.netValueDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    if (new_netValueDate.integerValue > net_netValueDate.integerValue) {
                        netModel.netValueDate = newModel.netValueDate;
                        netModel.unitNetValue = newModel.unitNetValue;
                    }
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success(netModel);
                    }
                });
                
            } failure:^(NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        failure(error);
                    }
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(netModel);
                }
            });
        }
        
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(error);
            }
        });
    }];
}

// 基金速查网-净值估算API
- (void)fetchFundEstimateValue:(NSString *)fundCode
                       success:(FMNetworkSuccessBlock)success
                       failure:(FMNetworkFailureBlock)failure {
    if (!fundCode || fundCode.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"基金代码不能为空"}];
            failure(error);
        }
        return;
    }

    // 使用基金速查网实时估值API
    NSString *urlString = [NSString stringWithFormat:@"https://m.dayfund.cn/ajs/ajaxdata.shtml?showtype=getfundvalue&fundcode=%@", fundCode];
    //urlString = @"https://m.dayfund.cn/ajs/ajaxdata.shtml?showtype=getfundvalue&fundcode=008164";

//    __weak typeof(self) weakSelf = self;
    [self requestWithUrl:urlString fundCode:fundCode success:^(NSString *jsonString) {
        // 解析基金数据
        // 返回格式示例：
        // 2026-02-09|1.0611|1.7111|0.0064|0.61%|0.00%|0.0000|1.0611|1.0547|2026-02-10|11:30:00
        
        NSArray<NSString *> *fields = [jsonString componentsSeparatedByString:@"|"];
        
        FMNetWorthModel *netModel = [[FMNetWorthModel alloc] init];
        netModel.fundCode = fundCode;
        if (fields.count >= 11) {
            netModel.netValueDate = fields[0];        // 净值日期
            netModel.unitNetValue = fields[1];        // 单位净值
            //netModel.accumulatedNetValue = fields[2]; // 累计净值
            //netModel.netValueGrowth = fields[3];      // 净值增长
            netModel.growthRate = fields[4];          // 净值增长率
            netModel.estimateGrowthRate = fields[5];  // 估算增长率
            //netModel.estimateGrowth = fields[6];      // 估算增长额
            netModel.estimateNetValue = fields[7];    // 估算净值
            //netModel.previousNetValue = fields[8];    // 前一日净值
            netModel.estimateDate = fields[9];        // 估值日期
            netModel.estimateTime = fields[10];       // 估值时间
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(netModel);
            }
        });
        
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failure) {
                failure(error);
            }
        });
    }];
}

- (void)fetchHotFunds:(FMNetworkSuccessBlock)success
              failure:(FMNetworkFailureBlock)failure {
    // 热门基金代码列表（可以根据实际需求调整）
    NSArray *hotFundCodes = @[
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
    ];

    // 批量获取热门基金的实时估值
    [self fetchMultipleFundsEstimate:hotFundCodes success:success failure:failure];
}

- (void)fetchFundHistoryData:(NSString *)fundCode
                    pageSize:(NSInteger)pageSize
                     success:(FMNetworkSuccessBlock)success
                     failure:(FMNetworkFailureBlock)failure {
    if (!fundCode || fundCode.length == 0) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"基金代码不能为空"}];
            failure(error);
        }
        return;
    }

    // 天天基金历史净值API
    // 接口地址: http://api.fund.eastmoney.com/f10/lsjz
    // 参数: fundCode=基金代码&pageIndex=1&pageSize=数量&startDate=&endDate=
    NSString *urlString = [NSString stringWithFormat:@"http://api.fund.eastmoney.com/f10/lsjz?callback=jQuery&fundCode=%@&PageIndex=1&PageSize=%ld", fundCode, (long)pageSize];

    NSLog(@"📡 [历史数据] 请求URL: %@", urlString);

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"❌ [历史数据] 网络请求失败: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error);
                }
            });
            return;
        }

        if (!data) {
            NSLog(@"❌ [历史数据] 未获取到数据");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    NSError *err = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"未获取到数据"}];
                    failure(err);
                }
            });
            return;
        }


        // 打印原始响应（前500个字符）
        NSString *rawResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (rawResponse.length > 500) {
            NSLog(@"✅ [历史数据] 原始响应（前500字符）: %@...", [rawResponse substringToIndex:500]);
        } else {
            NSLog(@"✅ [历史数据] 原始响应: %@", rawResponse);
        }

        // 解析历史净值数据
        NSArray *historyData = [self parseHistoryDataFromJSONP:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (historyData && historyData.count > 0) {
                NSLog(@"✅ [历史数据] 解析成功，共 %lu 条数据", (unsigned long)historyData.count);
                if (success) {
                    success(historyData);
                }
            } else {
                NSLog(@"❌ [历史数据] 解析失败或数据为空");
                if (failure) {
                    NSError *err = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"解析历史数据失败"}];
                    failure(err);
                }
            }
        });
    }];

    [task resume];
}

// 获取全量基金
- (void)fetchAllFundWithSuccess:(FMNetworkSuccessBlock)success
                     failure:(FMNetworkFailureBlock)failure {
    // 天天基金-全量基金API
    NSString *urlString = @"http://fund.eastmoney.com/js/fundcode_search.js";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"❌ [全量基金]网络请求失败: %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error);
                }
            });
            return;
        }
        
        if (!data) {
            NSLog(@"❌ [全量基金] 未获取到数据");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    NSError *err = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"未获取到数据"}];
                    failure(err);
                }
            });
            return;
        }
        
        // 打印原始响应（前500个字符）
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"var r = " withString:@""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@";" withString:@""];
        if (jsonString.length > 500) {
            NSLog(@"✅ [全量基金] 原始响应（前500字符）: %@...", [jsonString substringToIndex:500]);
        } else {
            NSLog(@"✅ [全量基金] 原始响应: %@", jsonString);
        }
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        // 解析数据
        NSError *parseError = nil;
        NSArray *allData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
        NSMutableArray *allList = [NSMutableArray array];
        for (NSArray *item in allData) {
            if (item.count > 2) {
                [allList addObject:@[item[0],item[2]]];
            }
        }
        
        if (![allList isKindOfClass:[NSArray class]]) {
            NSLog(@"❌ [解析] 返回数据不是字典类型");
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (allList && allList.count > 0) {
                NSLog(@"✅ [全量基金] 解析成功，共 %lu 条数据", (unsigned long)allList.count);
                if (success) {
                    success(allList);
                }
            } else {
                NSLog(@"❌ [全量基金] 解析失败或数据为空");
                if (failure) {
                    NSError *err = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"解析历史数据失败"}];
                    failure(err);
                }
            }
        });
    }];
    
    [task resume];
}

#pragma mark - 辅助方法

// 解析历史净值数据
- (NSArray<FMFundHistoryData *> *)parseHistoryDataFromJSONP:(NSData *)data {
    if (!data) {
        NSLog(@"❌ [解析] 数据为空");
        return nil;
    }

    NSString *jsonpString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!jsonpString) {
        NSLog(@"❌ [解析] 无法转换为字符串");
        return nil;
    }

    NSLog(@"🔍 [解析] 开始解析JSONP数据");

    // 移除JSONP包装: jQuery(...);
    NSRange startRange = [jsonpString rangeOfString:@"jQuery("];
    NSRange endRange = [jsonpString rangeOfString:@");" options:NSBackwardsSearch];

    if (startRange.location != NSNotFound && endRange.location != NSNotFound) {
        NSRange jsonRange = NSMakeRange(startRange.location + startRange.length, endRange.location - (startRange.location + startRange.length));
        jsonpString = [jsonpString substringWithRange:jsonRange];
        NSLog(@"✅ [解析] 成功移除JSONP包装");
    } else {
        NSLog(@"⚠️ [解析] 未找到JSONP包装，尝试直接解析");
    }

    NSData *jsonData = [jsonpString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *parseError = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];

    if (parseError) {
        NSLog(@"❌ [解析] JSON解析失败: %@", parseError.localizedDescription);
        return nil;
    }

    if (![jsonDict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"❌ [解析] 返回数据不是字典类型");
        return nil;
    }

    // 数据结构: {"Data": {"LSJZList": [{"FSRQ":"2024-01-15","DWJZ":"1.5000","JZZZL":"0.50"}]}}
    NSDictionary *dataDict = jsonDict[@"Data"];
    if (![dataDict isKindOfClass:[NSDictionary class]]) {
        NSLog(@"❌ [解析] Data字段不是字典类型");
        return nil;
    }

    NSArray *lsjzList = dataDict[@"LSJZList"];
    if (![lsjzList isKindOfClass:[NSArray class]]) {
        NSLog(@"❌ [解析] LSJZList字段不是数组类型");
        return nil;
    }

    NSMutableArray<FMFundHistoryData *> *historyData = [NSMutableArray array];

    for (NSDictionary *item in lsjzList) {
        if (![item isKindOfClass:[NSDictionary class]]) {
            continue;
        }

        NSString *date = item[@"FSRQ"];  // 净值日期
        NSString *netValueStr = item[@"DWJZ"];  // 单位净值
        NSString *dayRateStr = item[@"JZZZL"];  // 日增长率

        if (!date || !netValueStr) {
            continue;
        }

        // 转换数据类型
        NSNumber *netValue = @([netValueStr doubleValue]);
        NSNumber *dayRate = dayRateStr ? @([dayRateStr doubleValue]) : @(0);

        FMFundHistoryData *data = [FMFundHistoryData dataWithDate:date
                                                         netValue:netValue
                                                          dayRate:dayRate];
        [historyData addObject:data];
    }

    NSLog(@"✅ [解析] 成功解析 %lu 条历史数据", (unsigned long)historyData.count);

    // 反转数组，使最新的数据在最后
    return [[historyData reverseObjectEnumerator] allObjects];
}

- (NSString *)currentTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    return [formatter stringFromDate:[NSDate date]];
}

- (void)fetchFundCompanies:(FMNetworkSuccessBlock)success
                   failure:(FMNetworkFailureBlock)failure {
    // 基金公司列表API
    NSString *urlString = @"http://fund.eastmoney.com/js/jjjz_gs.js";

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error);
                }
            });
            return;
        }

        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    NSError *err = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"未获取到数据"}];
                    failure(err);
                }
            });
            return;
        }

        // 解析基金公司数据
        NSArray *companies = [self parseFundCompaniesFromJS:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (companies && companies.count > 0) {
                if (success) {
                    success(companies);
                }
            } else {
                if (failure) {
                    NSError *err = [NSError errorWithDomain:@"FMNetworkManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"解析基金公司数据失败"}];
                    failure(err);
                }
            }
        });
    }];

    [task resume];
}

// 解析基金公司数据
- (NSArray *)parseFundCompaniesFromJS:(NSData *)data {
    if (!data) {
        return nil;
    }

    NSString *jsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!jsString) {
        return nil;
    }

    // 移除 BOM 标记（如果存在）
    if ([jsString hasPrefix:@"\uFEFF"]) {
        jsString = [jsString substringFromIndex:1];
    }

    // 数据格式: var gs={op:[["81608035","安联基金"],["80163340","安信基金"],...]}
    // 提取 JSON 部分
    NSRange startRange = [jsString rangeOfString:@"var gs="];
    if (startRange.location == NSNotFound) {
        return nil;
    }

    NSString *jsonString = [jsString substringFromIndex:startRange.location + startRange.length];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"op:" withString:@"\"op\":"];

    // 移除末尾的分号
    if ([jsonString hasSuffix:@";"]) {
        jsonString = [jsonString substringToIndex:jsonString.length - 1];
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *parseError = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];

    if (parseError || ![jsonDict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    // 获取 op 数组
    NSArray *opArray = jsonDict[@"op"];
    if (![opArray isKindOfClass:[NSArray class]]) {
        return nil;
    }

    NSMutableArray *companies = [NSMutableArray array];

    for (id item in opArray) {
        if (![item isKindOfClass:[NSArray class]]) {
            continue;
        }

        NSArray *companyArray = (NSArray *)item;
        if (companyArray.count >= 2) {
            NSString *companyId = companyArray[0];
            NSString *companyName = companyArray[1];

            FMFundCompany *company = [FMFundCompany companyWithId:companyId name:companyName];
            [companies addObject:company];
        }
    }

    return companies;
}

// 解析基金详情数据（新接口）
- (FMFundDetailModel *)parseFundDetailFromJS:(NSString *)jsString {
    if (!jsString) {
        return nil;
    }
    
    jsString = [jsString stringByReplacingOccurrencesOfString:@" = " withString:@"="];
    
    FMFundDetailModel *fund = [[FMFundDetailModel alloc] init];

    NSRange rangeDate = [jsString rangeOfString:@"/*202"];
    if (rangeDate.length) {
        fund.updateTime = [jsString substringWithRange:NSMakeRange(rangeDate.location+2, 19)];
        jsString = [jsString substringFromIndex:rangeDate.location];
    }
    
    // 提取基金基本信息
    fund.fundName = [self extractJSVariable:@"fS_name" fromString:jsString];
    fund.fundCode = [self extractJSVariable:@"fS_code" fromString:jsString];
    
    // 解析十大重仓股票代码 stockCodesNew (是数组格式) 数组格式: ["1.688213","1.688484",...]
    fund.stockCodesNew = [self extractJSONArray:@"stockCodesNew" fromString:jsString];

    // 提取收益率数据
    NSString *syl_1n = [self extractJSVariable:@"syl_1n" fromString:jsString];
    NSString *syl_6y = [self extractJSVariable:@"syl_6y" fromString:jsString];
    NSString *syl_3y = [self extractJSVariable:@"syl_3y" fromString:jsString];
    NSString *syl_1y = [self extractJSVariable:@"syl_1y" fromString:jsString];

    if (syl_1n) fund.yearRate = @([syl_1n doubleValue]);
    if (syl_6y) fund.sixMonthRate = @([syl_6y doubleValue]);
    if (syl_3y) fund.threeMonthRate = @([syl_3y doubleValue]);
    if (syl_1y) fund.monthRate = @([syl_1y doubleValue]);

    // 解析 Data_netWorthTrend
    NSArray *netWorthTrendData = [self extractJSONArray:@"Data_netWorthTrend" fromString:jsString];
    if (netWorthTrendData) {
        NSMutableArray<FMNetWorthTrendData *> *trendDataArray = [NSMutableArray array];
        for (NSDictionary *item in netWorthTrendData) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSNumber *timestamp = item[@"x"];
                NSNumber *netWorth = item[@"y"];
                NSNumber *equityReturn = item[@"equityReturn"];
                NSString *unitMoney = item[@"unitMoney"];

                FMNetWorthTrendData *trendData = [FMNetWorthTrendData dataWithTimestamp:timestamp
                                                                               netWorth:netWorth
                                                                           equityReturn:equityReturn
                                                                              unitMoney:unitMoney];
                [trendDataArray addObject:trendData];
            }
        }
        fund.netWorthTrendData = trendDataArray;
    }

    // 解析 Data_grandTotal
    NSArray *grandTotalArray = [self extractJSONArray:@"Data_grandTotal" fromString:jsString];
    if (grandTotalArray && grandTotalArray.count > 0) {
        NSMutableArray<FMGrandTotalData *> *totalDataArray = [NSMutableArray array];

        // 遍历每个数据集（本基金、同类平均、沪深300等）
        for (NSDictionary *grandTotalDict in grandTotalArray) {
            if ([grandTotalDict isKindOfClass:[NSDictionary class]]) {
                NSString *name = grandTotalDict[@"name"];
                NSArray *dataArray = grandTotalDict[@"data"];

                if ([dataArray isKindOfClass:[NSArray class]]) {
                    NSMutableArray<FMGrandTotalDataItem *> *items = [NSMutableArray array];

                    // 遍历数据点
                    for (NSArray *item in dataArray) {
                        if ([item isKindOfClass:[NSArray class]] && item.count >= 2) {
                            NSNumber *timestamp = item[0];
                            NSNumber *totalReturn = item[1];

                            FMGrandTotalDataItem *dataItem = [FMGrandTotalDataItem itemWithTimestamp:timestamp
                                                                                         totalReturn:totalReturn];
                            [items addObject:dataItem];
                        }
                    }

                    // 创建 FMGrandTotalData 对象
                    FMGrandTotalData *totalData = [FMGrandTotalData dataWithName:name items:items];
                    [totalDataArray addObject:totalData];
                }
            }
        }

        fund.grandTotalData = totalDataArray;
    }

    return fund;
}

// 提取 JavaScript 变量值
- (NSString *)extractJSVariable:(NSString *)varName fromString:(NSString *)jsString {
    NSString *pattern = [NSString stringWithFormat:@"var %@=\"([^\"]*)\";", varName];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:jsString
                                                    options:0
                                                      range:NSMakeRange(0, jsString.length)];
    if (match && match.numberOfRanges > 1) {
        return [jsString substringWithRange:[match rangeAtIndex:1]];
    }
    return nil;
}

// 提取 JSON 数组
- (NSArray *)extractJSONArray:(NSString *)varName fromString:(NSString *)jsString {
    NSString *pattern = [NSString stringWithFormat:@"var %@\\s*=\\s*(\\[.*?\\]);", varName];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionDotMatchesLineSeparators
                                                                             error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:jsString
                                                    options:0
                                                      range:NSMakeRange(0, jsString.length)];
    if (match && match.numberOfRanges > 1) {
        NSString *jsonString = [jsString substringWithRange:[match rangeAtIndex:1]];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:0
                                                               error:&error];
        if (!error && [jsonArray isKindOfClass:[NSArray class]]) {
            return jsonArray;
        }
    }
    return nil;
}

// 获取热门基金销量排行（新接口）
- (void)fetchHotFundRanking:(NSString *)fundType
                  companyId:(NSString *)companyId
                  pageIndex:(NSInteger)pageIndex
                   pageSize:(NSInteger)pageSize
                    success:(FMNetworkSuccessBlock)success
                    failure:(FMNetworkFailureBlock)failure {
    // 构建 URL
    NSMutableString *urlString = [NSMutableString stringWithString:@"http://fund.eastmoney.com/data/FundGuideapi.aspx?dt=0"];

    // 添加基金类型参数
    if (fundType && fundType.length > 0) {
        [urlString appendFormat:@"&ft=%@", fundType];
    }
    // 添加基金公司code
    if (companyId && companyId.length > 0) {
        [urlString appendFormat:@"&cc=%@", companyId];
    }

    // 添加其他参数
    [urlString appendFormat:@"&sc=nzdf&st=desc&pi=%ld&pn=%ld&zf=diy&sh=list", (long)pageIndex, (long)pageSize];

    [self requestWithUrl:urlString fundCode:companyId success:^(NSString *jsonString) {
        // 解析返回数据
        NSArray *models = [self parseHotFundRankingData:jsonString];

        if (success) {
            success(models);
        }
    } failure:failure];
}

// 解析热门基金排行数据
- (NSArray *)parseHotFundRankingData:(NSString *)jsonString {
    if (!jsonString || jsonString.length == 0) {
        return @[];
    }

    // 移除 "var rankData =" 前缀
    NSString *cleanedString = [jsonString stringByReplacingOccurrencesOfString:@"var rankData =" withString:@""];
    cleanedString = [cleanedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // 解析 JSON
    NSData *jsonData = [cleanedString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error || ![jsonDict isKindOfClass:[NSDictionary class]]) {
        return @[];
    }

    // 获取 datas 数组
    NSArray *datasArray = jsonDict[@"datas"];
    if (![datasArray isKindOfClass:[NSArray class]]) {
        return @[];
    }

    // 解析每条数据
    NSMutableArray *models = [NSMutableArray array];
    for (NSString *dataString in datasArray) {
        if ([dataString isKindOfClass:[NSString class]]) {
            FMHotFundModel *model = [FMHotFundModel modelWithDataString:dataString];
            if (model) {
                [models addObject:model];
            }
        }
    }

    return models;
}

@end
