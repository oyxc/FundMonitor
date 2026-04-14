//
//  NSString+FMFindSubstrings.h
//  FundMonitor
//
//  字符串查找工具
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FMFindSubstrings)

// 查找所有匹配子字符串的位置
// @param substring 要查找的子字符串
// @return NSRange 数组，包含每个匹配的位置和长度
- (NSArray<NSValue *> *)fm_rangesOfString:(NSString *)substring;

// 查找所有匹配子字符串的位置（忽略大小写）
// @param substring 要查找的子字符串
// @return NSRange 数组
- (NSArray<NSValue *> *)fm_rangesOfString:(NSString *)substring options:(NSStringCompareOptions)options;

// 统计子字符串出现次数
// @param substring 要查找的子字符串
// @return 出现次数
- (NSUInteger)fm_occurrencesOfString:(NSString *)substring;

@end

NS_ASSUME_NONNULL_END
