//
//  FMGrandTotalData.m
//  FundMonitor
//

#import "FMGrandTotalData.h"

@implementation FMGrandTotalDataItem

+ (instancetype)itemWithTimestamp:(NSNumber *)timestamp totalReturn:(NSNumber *)totalReturn {
    FMGrandTotalDataItem *item = [[FMGrandTotalDataItem alloc] init];
    item.timestamp = timestamp;
    item.totalReturn = totalReturn;
    return item;
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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
    [coder encodeObject:self.totalReturn forKey:@"totalReturn"];
    [coder encodeObject:self.dateString forKey:@"dateString"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _timestamp = [coder decodeObjectForKey:@"timestamp"];
        _totalReturn = [coder decodeObjectForKey:@"totalReturn"];
        _dateString = [coder decodeObjectForKey:@"dateString"];
    }
    return self;
}

@end

@implementation FMGrandTotalData

+ (instancetype)dataWithName:(NSString *)name items:(NSArray<FMGrandTotalDataItem *> *)items {
    FMGrandTotalData *data = [[FMGrandTotalData alloc] init];
    data.name = name;
    data.data = items;
    return data;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.data forKey:@"data"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _data = [coder decodeObjectForKey:@"data"];
    }
    return self;
}

@end
