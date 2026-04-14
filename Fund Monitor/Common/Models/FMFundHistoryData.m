//
//  FMFundHistoryData.m
//  FundMonitor
//
//  基金历史数据模型
//

#import "FMFundHistoryData.h"

@implementation FMFundHistoryData

+ (instancetype)dataWithDate:(NSString *)date netValue:(NSNumber *)netValue dayRate:(NSNumber *)dayRate {
    FMFundHistoryData *data = [[FMFundHistoryData alloc] init];
    data.date = date;
    data.netValue = netValue;
    data.dayRate = dayRate;
    return data;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.netValue forKey:@"netValue"];
    [coder encodeObject:self.dayRate forKey:@"dayRate"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _date = [coder decodeObjectForKey:@"date"];
        _netValue = [coder decodeObjectForKey:@"netValue"];
        _dayRate = [coder decodeObjectForKey:@"dayRate"];
    }
    return self;
}

@end
