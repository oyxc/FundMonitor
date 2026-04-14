//
//  FMFundHistoryData.h
//  FundMonitor
//
//  基金历史数据模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMFundHistoryData : NSObject <NSCoding>

@property (nonatomic, copy) NSString *date;        // 日期（格式：YYYY-MM-DD）
@property (nonatomic, strong) NSNumber *netValue;  // 净值
@property (nonatomic, strong) NSNumber *dayRate;   // 日涨跌幅（百分比）

// 便利构造方法
+ (instancetype)dataWithDate:(NSString *)date netValue:(NSNumber *)netValue dayRate:(NSNumber *)dayRate;

@end

NS_ASSUME_NONNULL_END
