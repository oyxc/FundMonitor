//
//  FMFund.m
//  FundMonitor
//

#import "FMFund.h"

@implementation FMFund

+ (instancetype)fundWithCode:(NSString *)code name:(NSString *)name {
    FMFund *fund = [[FMFund alloc] init];
    fund.fundCode = code;
    fund.fundName = name;
    fund.isSelected = NO;
    fund.addTime = [NSDate date];
    fund.holdAmountByGroup = [NSMutableDictionary dictionary];
    fund.holdProfitByGroup = [NSMutableDictionary dictionary];
    fund.holdProfitRateByGroup = [NSMutableDictionary dictionary];
    fund.holdNetValueByGroup = [NSMutableDictionary dictionary];
    return fund;
}

- (void)setEstimateTime:(NSString *)estimateTime
{
    _estimateTime = estimateTime;
    
    self.estimateTimeInt = [[estimateTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
}

- (void)setLatestTime:(NSString *)latestTime
{
    _latestTime = latestTime;
    
    self.latestTimeInt = [[latestTime stringByReplacingOccurrencesOfString:@"-" withString:@""] integerValue];
}

#pragma mark - Per-Group Holdings

- (NSNumber *)holdAmountForGroup:(NSString *)groupId {
    if (!groupId) return @0;
    return self.holdAmountByGroup[groupId] ?: @0;
}

- (NSNumber *)holdProfitForGroup:(NSString *)groupId {
    if (!groupId) return @0;
    return self.holdProfitByGroup[groupId] ?: @0;
}

- (NSString *)holdProfitRateForGroup:(NSString *)groupId {
    if (!groupId) return @"0.00%";
    return self.holdProfitRateByGroup[groupId] ?: @"0.00%";
}

- (NSNumber *)holdNetValueForGroup:(NSString *)groupId {
    if (!groupId) return @0;
    return self.holdNetValueByGroup[groupId] ?: @0;
}

- (void)setHoldAmount:(NSNumber *)amount forGroup:(NSString *)groupId {
    if (!groupId) return;
    if (!self.holdAmountByGroup) {
        self.holdAmountByGroup = [NSMutableDictionary dictionary];
    }
    if (amount) {
        self.holdAmountByGroup[groupId] = amount;
    } else {
        [self.holdAmountByGroup removeObjectForKey:groupId];
    }
}

- (void)setHoldProfit:(NSNumber *)profit forGroup:(NSString *)groupId {
    if (!groupId) return;
    if (!self.holdProfitByGroup) {
        self.holdProfitByGroup = [NSMutableDictionary dictionary];
    }
    if (profit) {
        self.holdProfitByGroup[groupId] = profit;
    } else {
        [self.holdProfitByGroup removeObjectForKey:groupId];
    }
}

- (void)setHoldProfitRate:(NSString *)rate forGroup:(NSString *)groupId {
    if (!groupId) return;
    if (!self.holdProfitRateByGroup) {
        self.holdProfitRateByGroup = [NSMutableDictionary dictionary];
    }
    if (rate) {
        self.holdProfitRateByGroup[groupId] = rate;
    } else {
        [self.holdProfitRateByGroup removeObjectForKey:groupId];
    }
}

- (void)setHoldNetValue:(NSNumber *)netValue forGroup:(NSString *)groupId {
    if (!groupId) return;
    if (!self.holdNetValueByGroup) {
        self.holdNetValueByGroup = [NSMutableDictionary dictionary];
    }
    if (netValue) {
        self.holdNetValueByGroup[groupId] = netValue;
    } else {
        [self.holdNetValueByGroup removeObjectForKey:groupId];
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.fundCode forKey:@"fundCode"];
    [coder encodeObject:self.fundName forKey:@"fundName"];
    [coder encodeObject:self.fundType forKey:@"fundType"];
    [coder encodeObject:self.fundManager forKey:@"fundManager"];
    [coder encodeObject:self.fundCompany forKey:@"fundCompany"];

    [coder encodeObject:self.estimateTime forKey:@"estimateTime"];
    [coder encodeObject:self.estimateRate forKey:@"estimateRate"];
    [coder encodeObject:self.estimateValue forKey:@"estimateValue"];

    [coder encodeObject:self.latestTime forKey:@"latestTime"];
    [coder encodeObject:self.latestRate forKey:@"latestRate"];
    [coder encodeObject:self.latestValue forKey:@"latestValue"];

    // 新的按分组存储的持仓数据
    [coder encodeObject:self.holdAmountByGroup forKey:@"holdAmountByGroup"];
    [coder encodeObject:self.holdProfitByGroup forKey:@"holdProfitByGroup"];
    [coder encodeObject:self.holdProfitRateByGroup forKey:@"holdProfitRateByGroup"];
    [coder encodeObject:self.holdNetValueByGroup forKey:@"holdNetValueByGroup"];

    [coder encodeBool:self.isSelected forKey:@"isSelected"];
    [coder encodeObject:self.addTime forKey:@"addTime"];
    [coder encodeObject:self.groupIds forKey:@"groupIds"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.fundCode = [coder decodeObjectForKey:@"fundCode"];
        self.fundName = [coder decodeObjectForKey:@"fundName"];
        self.fundType = [coder decodeObjectForKey:@"fundType"];
        self.fundManager = [coder decodeObjectForKey:@"fundManager"];
        self.fundCompany = [coder decodeObjectForKey:@"fundCompany"];

        self.estimateTime = [coder decodeObjectForKey:@"estimateTime"];
        self.estimateRate = [coder decodeObjectForKey:@"estimateRate"];
        self.estimateValue = [coder decodeObjectForKey:@"estimateValue"];

        self.latestTime = [coder decodeObjectForKey:@"latestTime"];
        self.latestRate = [coder decodeObjectForKey:@"latestRate"];
        self.latestValue = [coder decodeObjectForKey:@"latestValue"];

        // 读取新的按分组存储的持仓数据
        self.holdAmountByGroup = [[coder decodeObjectForKey:@"holdAmountByGroup"] mutableCopy];
        self.holdProfitByGroup = [[coder decodeObjectForKey:@"holdProfitByGroup"] mutableCopy];
        self.holdProfitRateByGroup = [[coder decodeObjectForKey:@"holdProfitRateByGroup"] mutableCopy];
        self.holdNetValueByGroup = [[coder decodeObjectForKey:@"holdNetValueByGroup"] mutableCopy];

        // 如果没有新数据，初始化为空字典
        if (!self.holdAmountByGroup) {
            self.holdAmountByGroup = [NSMutableDictionary dictionary];
        }
        if (!self.holdProfitByGroup) {
            self.holdProfitByGroup = [NSMutableDictionary dictionary];
        }
        if (!self.holdProfitRateByGroup) {
            self.holdProfitRateByGroup = [NSMutableDictionary dictionary];
        }
        if (!self.holdNetValueByGroup) {
            self.holdNetValueByGroup = [NSMutableDictionary dictionary];
        }

        self.isSelected = [coder decodeBoolForKey:@"isSelected"];
        self.addTime = [coder decodeObjectForKey:@"addTime"];

        // 兼容旧数据：如果存在旧的 groupId，转换为 groupIds 数组
        NSString *oldGroupId = [coder decodeObjectForKey:@"groupId"];
        NSArray *newGroupIds = [coder decodeObjectForKey:@"groupIds"];
        if (newGroupIds) {
            self.groupIds = newGroupIds;
        } else if (oldGroupId) {
            self.groupIds = @[oldGroupId];
        } else {
            self.groupIds = @[];
        }
    }
    return self;
}

@end
