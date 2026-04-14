//
//  FMGroup.h
//  FundMonitor
//
//  分组数据模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMGroup : NSObject <NSCoding>

@property (nonatomic, copy) NSString *groupId;      // 分组ID
@property (nonatomic, copy) NSString *groupName;    // 分组名称
@property (nonatomic, strong) NSDate *createTime;   // 创建时间
@property (nonatomic, assign) NSInteger sortOrder;  // 排序顺序

// 便利构造方法
+ (instancetype)groupWithName:(NSString *)name;

// 默认分组
+ (instancetype)defaultGroup;

@end

NS_ASSUME_NONNULL_END
