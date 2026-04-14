//
//  FMHotFundModel.h
//  FundMonitor
//
//  热门基金数据模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMHotFundModel : NSObject

// 基金基本信息
@property (nonatomic, copy) NSString *fundCode;        // 基金代码
@property (nonatomic, copy) NSString *fundName;        // 基金名称
@property (nonatomic, copy) NSString *pinyinAbbr;      // 拼音缩写
@property (nonatomic, copy) NSString *fundType;        // 基金类型

// 收益率信息
@property (nonatomic, copy) NSString *rate1Week;       // 近1周收益率
@property (nonatomic, copy) NSString *rate1Month;      // 近1月收益率
@property (nonatomic, copy) NSString *rate3Month;      // 近3月收益率
@property (nonatomic, copy) NSString *rate6Month;      // 近6月收益率
@property (nonatomic, copy) NSString *rate1Year;       // 近1年收益率
@property (nonatomic, copy) NSString *rate2Year;       // 近2年收益率
@property (nonatomic, copy) NSString *rate3Year;       // 近3年收益率
@property (nonatomic, copy) NSString *rate5Year;       // 近5年收益率
@property (nonatomic, copy) NSString *rateThisYear;    // 今年来收益率

// 净值信息
@property (nonatomic, copy) NSString *netValueDate;    // 净值日期
@property (nonatomic, copy) NSString *unitNetValue;    // 单位净值
@property (nonatomic, copy) NSString *dayGrowthRate;   // 日增长率

// 便利构造方法
+ (instancetype)modelWithDataString:(NSString *)dataString;

@end

NS_ASSUME_NONNULL_END
