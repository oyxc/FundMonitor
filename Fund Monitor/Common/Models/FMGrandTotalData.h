//
//  FMGrandTotalData.h
//  FundMonitor
//
//  累计收益数据模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMGrandTotalDataItem : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *timestamp;      // 时间戳（毫秒）
@property (nonatomic, strong) NSNumber *totalReturn;    // 累计收益率

//自定义属性
@property (nonatomic, copy) NSString *dateString;       //转换后的时间
@property (nonatomic, assign) NSInteger dateStringInt;      //转换后的时间 int
@property (nonatomic, strong) NSNumber *cumulativeChange; // 相对于区间第一天的累计涨幅（百分比）

+ (instancetype)itemWithTimestamp:(NSNumber *)timestamp totalReturn:(NSNumber *)totalReturn;

@end



@interface FMGrandTotalData : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;      // 股票名称、同类平均、沪深300
@property (nonatomic, strong) NSArray<FMGrandTotalDataItem *> *data;

+ (instancetype)dataWithName:(NSString *)name items:(NSArray<FMGrandTotalDataItem *> *)items;

@end

NS_ASSUME_NONNULL_END
