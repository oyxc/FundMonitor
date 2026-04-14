//
//  DCLog.h
//  DCLogViewDemo
//
//  Created by DarielChen https://github.com/DarielChen/DCLog
//  Copyright © 2016年 DarielChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCLog : NSObject
/// 打印输入
+ (void)printLogFormat:(NSString *)format;
/// 是否启动log文件写入   yes  启动； No 不启动
///（目前 yes 情况下， xcode 调试台有时候不会输出，为找到方法）
+ (void)setLogViewEnabled:(BOOL)logViewEnabled;
/// 设置清理7天前的 log 日志， 默认 7天前
+ (void)removeLogFilesAtBeforeDay:(NSInteger)beforeDay;
/// 是否显示（取反）；例如，当前没有显示，调用即显示
+ (void)changeVisible;
/// 当前log是否可用模式
+ (BOOL)logViewEnabled;
/// 存入 info 到 log 日志中
+ (void)saveNSLogInfoToLogFileWithInfo:(NSString *)info;
@end
