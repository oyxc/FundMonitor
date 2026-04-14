//
//  FMGroup.m
//  FundMonitor
//

#import "FMGroup.h"

@implementation FMGroup

+ (instancetype)groupWithName:(NSString *)name {
    FMGroup *group = [[FMGroup alloc] init];
    group.groupId = [[NSUUID UUID] UUIDString];
    group.groupName = name;
    group.createTime = [NSDate date];
    group.sortOrder = 0;
    return group;
}

+ (instancetype)defaultGroup {
    FMGroup *group = [[FMGroup alloc] init];
    group.groupId = @"default";
    group.groupName = @"默认分组";
    group.createTime = [NSDate date];
    group.sortOrder = 0;
    return group;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.groupId forKey:@"groupId"];
    [coder encodeObject:self.groupName forKey:@"groupName"];
    [coder encodeObject:self.createTime forKey:@"createTime"];
    [coder encodeInteger:self.sortOrder forKey:@"sortOrder"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.groupId = [coder decodeObjectForKey:@"groupId"];
        self.groupName = [coder decodeObjectForKey:@"groupName"];
        self.createTime = [coder decodeObjectForKey:@"createTime"];
        self.sortOrder = [coder decodeIntegerForKey:@"sortOrder"];
    }
    return self;
}

@end
