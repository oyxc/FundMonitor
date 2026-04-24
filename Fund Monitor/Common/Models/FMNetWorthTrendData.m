//
//  FMNetWorthTrendData.m
//  FundMonitor
//

#import "FMNetWorthTrendData.h"

@implementation FMNetWorthTrendData

+ (instancetype)dataWithTimestamp:(NSNumber *)timestamp
                        netWorth:(NSNumber *)netWorth
                    equityReturn:(NSNumber *)equityReturn
                       unitMoney:(NSString *)unitMoney {
    FMNetWorthTrendData *data = [[FMNetWorthTrendData alloc] init];
    data.timestamp = timestamp;
    data.netWorth = netWorth;
    data.equityReturn = equityReturn;
    data.unitMoney = unitMoney ?: @"";
    return data;
}

- (NSString *)dateString
{
    if (!_dateString) {
        // 转换时间戳为日期字符串
        NSTimeInterval timeInterval = [_timestamp doubleValue] / 1000.0;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        _dateString = [formatter stringFromDate:date];
    }
    return _dateString;
}

- (NSInteger)dateStringInt
{
    if (_dateStringInt == 0) {
        _dateStringInt = [self.dateString stringByReplacingOccurrencesOfString:@"-" withString:@""].integerValue;
    }
    return _dateStringInt;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
    [coder encodeObject:self.netWorth forKey:@"netWorth"];
    [coder encodeObject:self.equityReturn forKey:@"equityReturn"];
    [coder encodeObject:self.unitMoney forKey:@"unitMoney"];
    [coder encodeObject:self.dateString forKey:@"dateString"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _timestamp = [coder decodeObjectForKey:@"timestamp"];
        _netWorth = [coder decodeObjectForKey:@"netWorth"];
        _equityReturn = [coder decodeObjectForKey:@"equityReturn"];
        _unitMoney = [coder decodeObjectForKey:@"unitMoney"];
        _dateString = [coder decodeObjectForKey:@"dateString"];
    }
    return self;
}

@end
