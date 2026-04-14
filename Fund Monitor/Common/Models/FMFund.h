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

@interface FMFund : NSObject <NSCoding>

// 基金基本信息
@property (nonatomic, copy) NSString *fundCode;             // 基金代码
@property (nonatomic, copy) NSString *fundName;             // 基金名称
@property (nonatomic, copy) NSString *fundType;             // 基金类型（股票型、混合型等）
@property (nonatomic, copy) NSString *fundManager;          // 基金经理
@property (nonatomic, copy) NSString *fundCompany;          // 基金公司

// 估值信息
@property (nonatomic, assign) NSInteger estimateTimeInt;    // 更新时间,Int类型，用于筛选
@property (nonatomic, copy) NSString *estimateTime;         // 估算时间
@property (nonatomic, copy) NSString *estimateRate;         // 估算涨跌幅
@property (nonatomic, copy) NSString *estimateValue;        // 估算净值

// 昨日信息
@property (nonatomic, assign) NSInteger latestTimeInt;      // 更新时间,Int类型，用于筛选
@property (nonatomic, copy) NSString *latestTime;           // 更新时间
@property (nonatomic, copy) NSString *latestRate;           // 最新涨跌幅
@property (nonatomic, copy) NSString *latestValue;          // 最新净值 / 昨日净值

// 按分组存储的持仓信息（新版本）
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *holdAmountByGroup;      // 按分组存储的持有金额
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *holdProfitByGroup;      // 按分组存储的持有收益
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *holdProfitRateByGroup;  // 按分组存储的收益率
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *holdNetValueByGroup;    // 按分组存储的持仓净值（成本净值）

// 自选相关
@property (nonatomic, assign) BOOL isSelected;         // 是否已加入自选
@property (nonatomic, strong) NSArray<NSString *> *groupIds;  // 所属分组ID数组（支持多个分组）
@property (nonatomic, strong) NSDate *addTime;         // 添加时间

// 便利方法：获取指定分组的持仓信息
- (NSNumber *)holdAmountForGroup:(NSString *)groupId;
- (NSNumber *)holdProfitForGroup:(NSString *)groupId;
- (NSString *)holdProfitRateForGroup:(NSString *)groupId;
- (NSNumber *)holdNetValueForGroup:(NSString *)groupId;

// 便利方法：设置指定分组的持仓信息
- (void)setHoldAmount:(NSNumber *)amount forGroup:(NSString *)groupId;
- (void)setHoldProfit:(NSNumber *)profit forGroup:(NSString *)groupId;
- (void)setHoldProfitRate:(NSString *)rate forGroup:(NSString *)groupId;
- (void)setHoldNetValue:(NSNumber *)netValue forGroup:(NSString *)groupId;

// 便利构造方法
+ (instancetype)fundWithCode:(NSString *)code name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
