//
//  AppDelegate.m
//  FundMonitor
//

#import "AppDelegate.h"
#import "FMMainTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 创建窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    // 设置根控制器
    FMMainTabBarController *tabBarController = [[FMMainTabBarController alloc] init];
    self.window.rootViewController = tabBarController;

    [self.window makeKeyAndVisible];
    
    NSLog(@"----------开启log日志记录----------");
    [DCLog setLogViewEnabled:YES];
    
    [self testCode];

    return YES;
}

- (void)testCode
{
    NSArray *list = @[
        @[@"qwer",@"qwerttyy"],
        @[@"qwe4r5",@"qwertt45yy"],
    ];
    // 筛选出子数组中至少有一个元素包含 "qwer" 的数组
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $item, $item CONTAINS[cd] %@).@count > 0", @"qwertt45"];
    
    NSArray *filtered = [list filteredArrayUsingPredicate:predicate];
    
    NSLog(@"筛选结果: %@", filtered);
}

@end
