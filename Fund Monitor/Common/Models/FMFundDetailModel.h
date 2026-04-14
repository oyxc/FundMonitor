//
//  FMFund.h
//  FundMonitor
//
//  基金数据模型
//

#import <Foundation/Foundation.h>

@class FMFundHistoryData;
@class FMNetWorthTrendData;
@class FMGrandTotalData;

NS_ASSUME_NONNULL_BEGIN

@interface FMFundDetailModel : NSObject

// 基金基本信息
@property (nonatomic, copy) NSString *fundCode;        // 基金代码
@property (nonatomic, copy) NSString *fundName;        // 基金名称
@property (nonatomic, copy) NSString *updateTime;      // 更新时间

// 收益率数据
@property (nonatomic, strong) NSNumber *yearRate;      // 近1年收益率（百分比）
@property (nonatomic, strong) NSNumber *monthRate;     // 近1月收益率
@property (nonatomic, strong) NSNumber *threeMonthRate; // 近3月收益率
@property (nonatomic, strong) NSNumber *sixMonthRate;  // 近6月收益率

@property (nonatomic, strong) NSArray<FMNetWorthTrendData *> *netWorthTrendData;  // 单位净值走势数据
@property (nonatomic, strong) NSArray<FMGrandTotalData *> *grandTotalData;  // 累计收益数据

// 十大重仓股票代码
@property (nonatomic, copy) NSArray<NSString *> *stockCodesNew;  // 股票代码列表（如 @[@"1.688213", @"1.688484", ...]）

@end

NS_ASSUME_NONNULL_END
