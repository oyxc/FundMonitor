//
//  FMNetWorthModel.h
//  Fund Monitor
//
//  Created by oyxc mac on 2026/2/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMNetWorthModel : NSObject

@property (nonatomic, copy) NSString *fundCode;
@property (nonatomic, copy) NSString *netValueDate;             // 净值日期
@property (nonatomic, copy) NSString *unitNetValue;             // 单位净值
//@property (nonatomic, copy) NSString *accumulatedNetValue;    // 累计净值
//@property (nonatomic, copy) NSString *netValueGrowth;         // 净值增长
@property (nonatomic, copy) NSString *growthRate;               // 净值增长率
@property (nonatomic, copy) NSString *estimateGrowthRate;       // 估算增长率
//@property (nonatomic, copy) NSString *estimateGrowth;         // 估算增长额
@property (nonatomic, copy) NSString *estimateNetValue;         // 估算净值
//@property (nonatomic, copy) NSString *previousNetValue;       // 前一日净值
@property (nonatomic, copy) NSString *estimateDate;             // 估值日期
@property (nonatomic, copy) NSString *estimateTime;             // 估值时间

@end

NS_ASSUME_NONNULL_END
