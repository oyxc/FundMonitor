//
//  FMNetWorthTrendData.h
//  FundMonitor
//
//  净值走势数据模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMNetWorthTrendData : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *timestamp;      // 时间戳（毫秒）
@property (nonatomic, strong) NSNumber *netWorth;       // 净值
@property (nonatomic, strong) NSNumber *equityReturn;   // 净值回报率
@property (nonatomic, copy) NSString *unitMoney;        // 每份派送金

//自定义属性
@property (nonatomic, copy) NSString *dateString;       //转换后的时间

+ (instancetype)dataWithTimestamp:(NSNumber *)timestamp
                        netWorth:(NSNumber *)netWorth
                    equityReturn:(NSNumber *)equityReturn
                       unitMoney:(NSString *)unitMoney;

@end

NS_ASSUME_NONNULL_END
