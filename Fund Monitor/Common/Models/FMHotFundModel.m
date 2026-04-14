//
//  FMHotFundModel.m
//  FundMonitor
//

#import "FMHotFundModel.h"

@implementation FMHotFundModel

+ (instancetype)modelWithDataString:(NSString *)dataString {
    if (!dataString || dataString.length == 0) {
        return nil;
    }

    //"161725,招商中证白酒指数(LOF)A,ZSZZBJZSLOFA,指数型-股票,0.69,-3.77,-1.23,-11.09,-7.29,-5.25,-18.8,-42.39,-53.02,,1,2026-02-11,0.7148,-0.11,1,0.10%,10,1,1.00%,0.10%",
    // 数据格式：基金代码,基金名称,拼音缩写,基金类型,今年来,近1周,近1月,近3月,近6月,近1年,近2年,近3年,近5年,成立来,状态,净值日期,单位净值,日增长率,申购状态,手续费,起购金额,是否有优惠,原费率,优惠费率
    NSArray<NSString *> *components = [dataString componentsSeparatedByString:@","];

    if (components.count < 18) {
        return nil;
    }

    FMHotFundModel *model = [[FMHotFundModel alloc] init];
    model.fundCode = components[0];
    model.fundName = components[1];
    model.pinyinAbbr = components[2];
    model.fundType = components[3];
    model.rateThisYear = components[4];
    model.rate1Week = components[5];
    model.rate1Month = components[6];
    model.rate3Month = components[7];
    model.rate6Month = components[8];
    model.rate1Year = components[9];
    model.rate2Year = components[10];
    model.rate3Year = components[11];
    model.rate5Year = components[12];
    // components[13] 是自定义字段，跳过
    // components[14] 是状态字段，跳过
    model.netValueDate = components[15];
    model.unitNetValue = components[16];
    model.dayGrowthRate = components[17];

    return model;
}

@end
