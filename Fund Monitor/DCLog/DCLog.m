//
//  DCLog.m
//  DCLogViewDemo
//
//  Created by DarielChen https://github.com/DarielChen/DCLog
//  Copyright © 2016年 DarielChen. All rights reserved.
//

#import "DCLog.h"
#import "DCLogView.h"
#define CarshFileName @"WFTCrashInfo.log"

#define DCWeakSelf __weak typeof(self) weakSelf = self;

@interface DCLog()

@property (nonatomic, copy) NSString *crashInfoString;

@property (nonatomic, strong) DCLogView *logView;

@property (nonatomic, strong) NSTimer *time;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger beforeDay;
@property(nonatomic, assign) BOOL logViewEnabled;
@property(nonatomic, assign) BOOL isShow;
@property (nonatomic, copy) NSString *logInfoPath;
@property (nonatomic, copy) NSString *logTime;
@end

@implementation DCLog

+ (void)printLogFormat:(NSString *)format {
#if UAT
    NSString *logStr = [NSString stringWithFormat:@"----------\nTIME:%s FUNCTION:%s FILE:%s(%d行) \nuserId:%@\n %@\n------", __TIME__,__PRETTY_FUNCTION__, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__,TQDataManage.sharedData.userId,format];
    [DCLog saveNSLogInfoToLogFileWithInfo:logStr];
#endif
}

+ (void)setLogViewEnabled:(BOOL)logViewEnabled {
    [DCLog shareLog].logViewEnabled = logViewEnabled;
    [DCLog startRecord];
}

+ (void)startRecord {
    if ([DCLog shareLog].logViewEnabled == YES) {
        NSSetUncaughtExceptionHandler(&UncaughtCrashExceptionHandler);
        [[DCLog shareLog] saveLogInfo];
    }
}

+ (void)changeVisible {
    if ([DCLog shareLog].logViewEnabled == YES) {
        DCLog *log = [DCLog shareLog];
        log.time ? [log hideLogView] : [log showLogView];
    }
}

/// 当前log是否可用模式
+ (BOOL)logViewEnabled; {
    return [DCLog shareLog].logViewEnabled;
}

+ (instancetype)shareLog {
    static DCLog *log = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = [[DCLog alloc] init];
        log.beforeDay = 7;
        [log readCarshInfo];
    });
    return log;
}

- (DCLogView *)logView {
    if (!_logView) {
        _logView = [[DCLogView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _logView.backgroundColor = [UIColor grayColor];
        
        _logView.hidden = YES;
        _logView.alpha = 0.0f;
    }
    return _logView;
}

/// 设置清理7天前的 log 日志， 默认 7天前
+ (void)removeLogFilesAtBeforeDay:(NSInteger)beforeDay {
    [DCLog shareLog].beforeDay = beforeDay >= 0 ?  beforeDay : 7;
}

void UncaughtCrashExceptionHandler(NSException *exception) {

    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSString *time = [dateformat stringFromDate:[NSDate new]];
    // 异常的堆栈信息
    NSArray *stackArray = [exception callStackSymbols];
    // 出现异常的原因
    NSString *reason = [exception reason];
    // 异常名称
    NSString *name = [exception name];

    NSString *crashInfo = [NSString stringWithFormat:@"\n\n*************************************crash_log*****************************************\n异常名称：%@\n异常发生时间：%@\n异常对应的log时间：%@\n异常原因：%@\n异常堆栈信息：%@",name, time,[[DCLog shareLog] logTime], reason,stackArray];
    NSLog(@"%@", crashInfo);
    
    // 有时候 NSLog(@"%@", crashInfo);  没有写成功，所以直接用 saveCrashInfoToLogWithInfo 再写入nslog一遍，有可能出现两边
    [[DCLog shareLog] saveNSLogToLogFileWithInfo:crashInfo];
    
    [[DCLog shareLog] saveCrashInfo:crashInfo];
    
}

+ (void)saveNSLogInfoToLogFileWithInfo:(NSString *)info {
    NSString *logText = [[DCLog shareLog] readLogInfo];
    if (logText) {
        logText = [logText stringByAppendingString:info];
    } else {
        logText = logText;
    }
    [logText writeToFile:[DCLog shareLog].logInfoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)saveNSLogToLogFileWithInfo:(NSString *)info {
    [DCLog saveNSLogInfoToLogFileWithInfo:info];
}

- (NSString *)crashLogFilesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/CrashLog"];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    // 先判断是否有 CrashLog 文件夹，没有创建一个
    if (![defaultManager fileExistsAtPath:documentDirectory]) {
        [defaultManager createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return documentDirectory;
}

- (NSString *)logInfoPath {
    if (_logInfoPath == nil) {
        NSString *fileName = [NSString stringWithFormat:@"CrashLog_%@.log",[self logTime]];
        NSString *logFilePath = [[self crashLogFilesPath] stringByAppendingPathComponent:fileName];
        _logInfoPath = logFilePath;
    }
    return _logInfoPath;
}

- (NSString *)logTime {
    if (_logTime == nil) {
        NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
        [dateformat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
        _logTime = [dateformat stringFromDate:[NSDate date]];
    }
    return _logTime;
}

- (void)saveLogInfo {
    NSString *nslogPath = self.logInfoPath;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    //先删除已经存在的文件
    [defaultManager removeItemAtPath:nslogPath error:nil];
    // 删除 大于
    [self removeOverTimeDayLog:defaultManager];

    // 将log输入到文件
//    freopen([nslogPath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stdout);
//    freopen([nslogPath cStringUsingEncoding:NSASCIIStringEncoding],"a+", stderr);
}

- (void)removeOverTimeDayLog:(NSFileManager *)defaultManager {
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];

    NSArray<NSString *> *files = [defaultManager subpathsAtPath:[self crashLogFilesPath]];
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull oldPath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *oldTime = [self fileTimeWithFilePath:oldPath];
        NSDate *oldDate = [dateformat dateFromString:oldTime];
    }];
}

- (NSString *)fileTimeWithFilePath:(NSString *)path {
    return [[path componentsSeparatedByString:@"_"].lastObject componentsSeparatedByString:@".log"].firstObject;
}

- (NSString *)readLogInfo {
    NSData *logData = [NSData dataWithContentsOfFile:self.logInfoPath];
    NSString *logText = [[NSString alloc]initWithData:logData encoding:NSUTF8StringEncoding];
    return logText;
}

- (void)saveCrashInfo:(NSString *)crashInfo {
    if (self.crashInfoString) {
        self.crashInfoString = [self.crashInfoString stringByAppendingString:crashInfo];
    } else {
        self.crashInfoString = crashInfo;
    }
    [self.crashInfoString writeToFile:[self loadPathWithName:CarshFileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)readCarshInfo {
    NSData *crashData = [NSData dataWithContentsOfFile: [self loadPathWithName:CarshFileName]];
    NSString *crashText = [[NSString alloc]initWithData:crashData encoding:NSUTF8StringEncoding];
    self.crashInfoString = crashText;
    return crashText;
}

- (void)hideLogView {
    
    [UIView animateWithDuration:0.4 animations:^{
        self.logView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.logView removeFromSuperview];
    }];
    self.logView.hidden = YES;
    
    [self.time invalidate];
    self.time = nil;
}

- (void)showLogView {
    
    [[self getWindow] addSubview:self.logView];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.logView.alpha = 1.0f;
    }];
    
    self.logView.hidden = NO;
    
    self.time = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(refreshLogText) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.time forMode:NSDefaultRunLoopMode];

    DCWeakSelf;
    self.logView.indexBlock = ^(NSInteger index) {
        weakSelf.index = index;
    };
    

    self.logView.CopyButtonIndexBlock = ^(NSInteger index,NSString *contentLog) {
        [weakSelf showAlertViewWithContentLog:contentLog];
    };
    
    self.logView.CleanButtonIndexBlock = ^(NSInteger index) {
        if (index == 0) {
            [[NSFileManager defaultManager]removeItemAtPath:weakSelf.logInfoPath error:nil];
            [weakSelf saveLogInfo];
        }else if (index == 1) {
            [[NSFileManager defaultManager]removeItemAtPath:[weakSelf loadPathWithName:CarshFileName] error:nil];
        }
    };
}

- (void)showAlertViewWithContentLog:(NSString *)log {
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"复制提醒" message:@"是否复制到粘贴板上" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alerController addAction:cancelAction];
    
    UIAlertAction *confirAction = [UIAlertAction actionWithTitle:@"确定复制" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = log;
        
    }];
    [alerController addAction:confirAction];
    
    [[self topViewController] presentViewController:alerController animated:YES completion:nil];
}

- (void)refreshLogText {
    if (self.index == 0) {
        [self.logView updateLog:[self readLogInfo]];
    }else if (self.index == 1) {
        [self.logView updateLog:[self readCarshInfo]];
    }
}

- (NSString *)loadPathWithName:(NSString *)fileName {
    NSString *documentDirPath = [self crashLogFilesPath];
    NSString *path = [documentDirPath stringByAppendingPathComponent:fileName];
    return path;
}

- (NSDate *)getCurrentDate {
    NSDate *now = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [zone secondsFromGMTForDate:now];
    NSDate *newDate = [now dateByAddingTimeInterval:seconds];
    return newDate;
}

- (UIWindow *)getWindow {
    UIWindow *window;
    if (@available(iOS 13.0, *)) {
        window = [UIApplication sharedApplication].windows.firstObject;
    }else{
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}

- (UIViewController *)topViewController {
    return [self topViewController:nil];
}

- (UIViewController *)topViewController:(UIViewController* _Nullable)controller {
    UIViewController *vc = controller ?: UIApplication.sharedApplication.delegate.window.rootViewController;
    
    // 同一个层级
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController*)vc;
        vc = tab.selectedViewController;
    }
    
    if ([vc isKindOfClass:UINavigationController.class]) {
        UINavigationController *nav = (UINavigationController*)vc;
        vc = nav.topViewController;
    }
    
//    if ([vc isKindOfClass:NSClassFromString(@"JTWrapViewController")]) {
//        vc = [vc childViewControllers].firstObject.childViewControllers.firstObject?:[vc childViewControllers].firstObject?:vc;
//    }
//
    /* 不需要判断presentedViewController层  一般都是些系统的东西，本项目presentedViewController层不需要遍历
    // 另一个层级
    if (vc.presentedViewController && ![vc.presentedViewController isKindOfClass:UIAlertController.class]) {
        vc = vc.presentedViewController;
        vc = [self topViewController:vc];
    }
     */
    return vc;
}


@end
