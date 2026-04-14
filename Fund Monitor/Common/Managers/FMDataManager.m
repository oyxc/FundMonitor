//
//  FMDataManager.m
//  FundMonitor
//

#import "FMDataManager.h"

static NSString *const kSelectedFundsKey = @"SelectedFunds";
static NSString *const kGroupsKey = @"Groups";
static NSString *const kHotFundsKey = @"HotFunds";

@interface FMDataManager ()

@property (nonatomic, strong) NSMutableArray<FMFund *> *selectedFunds;
@property (nonatomic, strong) NSMutableArray<FMGroup *> *groups;
@property (nonatomic, strong) NSMutableArray<FMFund *> *hotFunds;

@end

@implementation FMDataManager

+ (instancetype)sharedManager {
    static FMDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMDataManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadData];
    }
    return self;
}

#pragma mark - 数据加载和保存

- (void)loadData {
    // 加载自选基金
    NSData *fundsData = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedFundsKey];
    if (fundsData) {
        self.selectedFunds = [NSKeyedUnarchiver unarchiveObjectWithData:fundsData];
    } else {
        self.selectedFunds = [NSMutableArray array];
    }

    // 加载分组
    NSData *groupsData = [[NSUserDefaults standardUserDefaults] objectForKey:kGroupsKey];
    if (groupsData) {
        self.groups = [NSKeyedUnarchiver unarchiveObjectWithData:groupsData];
    } else {
        self.groups = [NSMutableArray array];
        // 添加默认分组
        [self.groups addObject:[FMGroup defaultGroup]];
    }

    // 加载热门基金缓存
    NSData *hotFundsData = [[NSUserDefaults standardUserDefaults] objectForKey:kHotFundsKey];
    if (hotFundsData) {
        self.hotFunds = [NSKeyedUnarchiver unarchiveObjectWithData:hotFundsData];
    } else {
        self.hotFunds = [NSMutableArray array];
    }
}

- (void)saveFunds {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.selectedFunds];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kSelectedFundsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveGroups {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.groups];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kGroupsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveHotFundsCache {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.hotFunds];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kHotFundsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 基金管理

- (NSArray<FMFund *> *)getAllSelectedFunds {
    return [self.selectedFunds copy];
}

- (NSArray<FMFund *> *)getFundsInGroup:(NSString *)groupId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY groupIds == %@", groupId];
    return [self.selectedFunds filteredArrayUsingPredicate:predicate];
}

- (BOOL)addSelectedFund:(FMFund *)fund toGroup:(NSString *)groupId {
    if (!fund || !fund.fundCode) {
        return NO;
    }

    groupId = groupId ?: @"default";

    // 检查是否已存在
    NSInteger existingIndex = [self indexOfFundWithCode:fund.fundCode];
    if (existingIndex != NSNotFound) {
        // 基金已存在，将分组添加到数组中（如果还不存在）
        FMFund *existingFund = self.selectedFunds[existingIndex];
        NSMutableArray *groupIds = existingFund.groupIds ? [existingFund.groupIds mutableCopy] : [NSMutableArray array];

        if (![groupIds containsObject:groupId]) {
            NSLog(@"添加基金 %@ 到新分组 %@", fund.fundCode, groupId);

            [groupIds addObject:groupId];
            existingFund.groupIds = [groupIds copy];
        }
        
        NSLog(@"添加前 holdAmountByGroup: %@", existingFund.holdAmountByGroup);
        
        // 更新持仓数据
        if (fund.holdAmountByGroup && fund.holdAmountByGroup[groupId]) {
            existingFund.holdAmountByGroup[groupId] = fund.holdAmountByGroup[groupId];
        }
        if (fund.holdProfitByGroup && fund.holdProfitByGroup[groupId]) {
            existingFund.holdProfitByGroup[groupId] = fund.holdProfitByGroup[groupId];
        }
        if (fund.holdProfitRateByGroup && fund.holdProfitRateByGroup[groupId]) {
            existingFund.holdProfitRateByGroup[groupId] = fund.holdProfitRateByGroup[groupId];
        }
        if (fund.holdNetValueByGroup && fund.holdNetValueByGroup[groupId]) {
            existingFund.holdNetValueByGroup[groupId] = fund.holdNetValueByGroup[groupId];
        }
        
        NSLog(@"添加后 holdAmountByGroup: %@", existingFund.holdAmountByGroup);
        
        [self saveFunds];
        
        return YES;
    }

    // 基金不存在，添加新基金
    // 清除传入 fund 对象中的所有持仓数据，避免带入其他分组的持仓
    fund.isSelected = YES;
    fund.groupIds = @[groupId];
    fund.addTime = [NSDate date];

    [self.selectedFunds addObject:fund];
    [self saveFunds];

    return YES;
}

- (BOOL)removeSelectedFund:(NSString *)fundCode {
    if (!fundCode) {
        return NO;
    }

    NSInteger index = [self indexOfFundWithCode:fundCode];
    if (index != NSNotFound) {
        [self.selectedFunds removeObjectAtIndex:index];
        [self saveFunds];
        return YES;
    }

    return NO;
}

- (BOOL)updateFund:(FMFund *)fund {
    if (!fund || !fund.fundCode) {
        return NO;
    }

    NSInteger index = [self indexOfFundWithCode:fund.fundCode];
    if (index != NSNotFound) {
        [self.selectedFunds replaceObjectAtIndex:index withObject:fund];
        [self saveFunds];
        return YES;
    }

    return NO;
}

- (BOOL)moveFund:(NSString *)fundCode toGroup:(NSString *)groupId {
    if (!fundCode || !groupId) {
        return NO;
    }

    NSInteger index = [self indexOfFundWithCode:fundCode];
    if (index != NSNotFound) {
        FMFund *fund = self.selectedFunds[index];
        // 替换为只包含新分组的数组
        fund.groupIds = @[groupId];
        [self saveFunds];
        return YES;
    }

    return NO;
}

- (BOOL)removeFund:(NSString *)fundCode fromGroup:(NSString *)groupId {
    if (!fundCode || !groupId) {
        return NO;
    }

    NSInteger index = [self indexOfFundWithCode:fundCode];
    if (index != NSNotFound) {
        FMFund *fund = self.selectedFunds[index];
        NSMutableArray *groupIds = [fund.groupIds mutableCopy];

        if ([groupIds containsObject:groupId]) {
            [groupIds removeObject:groupId];
            fund.groupIds = [groupIds copy];
            [self saveFunds];
            return YES;
        }
    }

    return NO;
}

- (BOOL)isFundSelected:(NSString *)fundCode {
    return [self indexOfFundWithCode:fundCode] != NSNotFound;
}

- (NSInteger)indexOfFundWithCode:(NSString *)fundCode {
    return [self.selectedFunds indexOfObjectPassingTest:^BOOL(FMFund *fund, NSUInteger idx, BOOL *stop) {
        return [fund.fundCode isEqualToString:fundCode];
    }];
}

#pragma mark - 分组管理

- (NSArray<FMGroup *> *)getAllGroups {
    return [self.groups copy];
}

- (BOOL)addGroup:(FMGroup *)group {
    if (!group || !group.groupId) {
        return NO;
    }

    [self.groups addObject:group];
    [self saveGroups];

    return YES;
}

- (BOOL)removeGroup:(NSString *)groupId {
    if (!groupId || [groupId isEqualToString:@"default"]) {
        // 不允许删除默认分组
        return NO;
    }

    NSInteger index = [self indexOfGroupWithId:groupId];
    if (index != NSNotFound) {
        // 从所有基金的分组数组中移除该分组ID
        for (FMFund *fund in self.selectedFunds) {
            if ([fund.groupIds containsObject:groupId]) {
                NSMutableArray *groupIds = [fund.groupIds mutableCopy];
                [groupIds removeObject:groupId];

                // 如果移除后没有分组了，添加到默认分组
                if (groupIds.count == 0) {
                    groupIds = [@[@"default"] mutableCopy];
                }

                fund.groupIds = [groupIds copy];
            }
        }

        [self.groups removeObjectAtIndex:index];
        [self saveGroups];
        [self saveFunds];

        return YES;
    }

    return NO;
}

- (BOOL)updateGroup:(FMGroup *)group {
    if (!group || !group.groupId) {
        return NO;
    }

    NSInteger index = [self indexOfGroupWithId:group.groupId];
    if (index != NSNotFound) {
        [self.groups replaceObjectAtIndex:index withObject:group];
        [self saveGroups];
        return YES;
    }

    return NO;
}

- (FMGroup *)getDefaultGroup {
    for (FMGroup *group in self.groups) {
        if ([group.groupId isEqualToString:@"default"]) {
            return group;
        }
    }

    // 如果没有默认分组，创建一个
    FMGroup *defaultGroup = [FMGroup defaultGroup];
    [self.groups insertObject:defaultGroup atIndex:0];
    [self saveGroups];

    return defaultGroup;
}

- (NSInteger)indexOfGroupWithId:(NSString *)groupId {
    return [self.groups indexOfObjectPassingTest:^BOOL(FMGroup *group, NSUInteger idx, BOOL *stop) {
        return [group.groupId isEqualToString:groupId];
    }];
}

#pragma mark - 热门基金

- (void)saveHotFunds:(NSArray<FMFund *> *)funds {
    self.hotFunds = [funds mutableCopy];
    [self saveHotFundsCache];
}

- (NSArray<FMFund *> *)getHotFunds {
    return [self.hotFunds copy];
}

@end
