//
//  NSString+FMFindSubstrings.m
//  FundMonitor
//
//  字符串查找工具
//

#import "NSString+FMFindSubstrings.h"

@implementation NSString (FMFindSubstrings)

- (NSArray<NSValue *> *)fm_rangesOfString:(NSString *)substring {
    return [self fm_rangesOfString:substring options:0];
}

- (NSArray<NSValue *> *)fm_rangesOfString:(NSString *)substring options:(NSStringCompareOptions)options {
    if (!substring || substring.length == 0) {
        return @[];
    }

    NSMutableArray<NSValue *> *ranges = [NSMutableArray array];

    NSRange searchRange = NSMakeRange(0, self.length);
    NSRange foundRange;

    while (searchRange.location < self.length) {
        foundRange = [self rangeOfString:substring
                                  options:options
                                    range:searchRange];

        if (foundRange.location != NSNotFound) {
            [ranges addObject:[NSValue valueWithRange:foundRange]];

            // 更新搜索范围，从匹配位置之后继续搜索
            searchRange.location = foundRange.location + foundRange.length;
            searchRange.length = self.length - searchRange.location;
        } else {
            break;
        }
    }

    return [ranges copy];
}

- (NSUInteger)fm_occurrencesOfString:(NSString *)substring {
    return [[self fm_rangesOfString:substring] count];
}

@end
