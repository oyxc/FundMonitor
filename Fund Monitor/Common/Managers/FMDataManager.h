//
//  FMDataManager.h
//  FundMonitor
//
//  数据管理类 - 负责本地数据持久化
//

#import <Foundation/Foundation.h>
#import "FMFund.h"
#import "FMGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface FMDataManager : NSObject

// 单例
+ (instancetype)sharedManager;

#pragma mark - 基金管理

// 获取所有自选基金
- (NSArray<FMFund *> *)getAllSelectedFunds;

// 根据分组获取基金
- (NSArray<FMFund *> *)getFundsInGroup:(NSString *)groupId;

// 添加自选基金
- (BOOL)addSelectedFund:(FMFund *)fund toGroup:(NSString *)groupId;

// 移除自选基金
- (BOOL)removeSelectedFund:(NSString *)fundCode;

// 更新基金信息
- (BOOL)updateFund:(FMFund *)fund;

// 移动基金到其他分组
- (BOOL)moveFund:(NSString *)fundCode toGroup:(NSString *)groupId;

// 从指定分组中移除基金（基金仍在其他分组中）
- (BOOL)removeFund:(NSString *)fundCode fromGroup:(NSString *)groupId;

// 检查基金是否已加入自选
- (BOOL)isFundSelected:(NSString *)fundCode;

#pragma mark - 分组管理

// 获取所有分组
- (NSArray<FMGroup *> *)getAllGroups;

// 添加分组
- (BOOL)addGroup:(FMGroup *)group;

// 删除分组
- (BOOL)removeGroup:(NSString *)groupId;

// 更新分组
- (BOOL)updateGroup:(FMGroup *)group;

// 获取默认分组
- (FMGroup *)getDefaultGroup;

#pragma mark - 热门基金

// 保存热门基金列表（缓存）
- (void)saveHotFunds:(NSArray<FMFund *> *)funds;

// 获取热门基金列表
- (NSArray<FMFund *> *)getHotFunds;

@end

NS_ASSUME_NONNULL_END
