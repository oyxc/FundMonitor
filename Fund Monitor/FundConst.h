

#ifndef FundConst_h
#define FundConst_h

#define iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})


//时间戳
#define TQTimeCurrent \
({\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];\
dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en"];\
NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];\
(currentTime);})


//***********************************************
//**********      日志输出宏定义      *************
//***********************************************

#import "DCLog.h"

//输出
#define NSLog(format, ...)\
do {  \
NSString *formatStr = [NSString stringWithFormat:format, ##__VA_ARGS__]; \
NSString *logStr = [NSString stringWithFormat:@"\nTIME:%@ FILE:%s(%d行) FUNCTION:%s %@\n", TQTimeCurrent,[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__LINE__,__PRETTY_FUNCTION__,formatStr]; \
[DCLog saveNSLogInfoToLogFileWithInfo:logStr];\
fprintf(stderr,"%s\n",[logStr UTF8String]);   \
} while (0)



#endif /* FundConst_h */









