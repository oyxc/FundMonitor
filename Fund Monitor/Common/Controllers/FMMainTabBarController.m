//
//  FMMainTabBarController.m
//  FundMonitor
//

#import "FMMainTabBarController.h"
#import "FMMyFundsViewController.h"
#import "FMHotFundsViewController.h"
#import "FMFundCompaniesViewController.h"
#import "FMSettingsViewController.h"
#import "FMSettingsManager.h"

@interface FMMainTabBarController ()

@end

@implementation FMMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViewControllers];
    [self setupAppearance];

    // 监听主题设置变更
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appearanceSettingDidChange)
                                                 name:@"AppearanceSettingDidChange"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViewControllers {
    // 自选基金
    FMMyFundsViewController *myFundsVC = [[FMMyFundsViewController alloc] init];
    UINavigationController *myFundsNav = [[UINavigationController alloc] initWithRootViewController:myFundsVC];
    myFundsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"自选"
                                                          image:[UIImage systemImageNamed:@"star"]
                                                  selectedImage:[UIImage systemImageNamed:@"star.fill"]];

    // 热门基金
    FMHotFundsViewController *hotFundsVC = [[FMHotFundsViewController alloc] init];
    UINavigationController *hotFundsNav = [[UINavigationController alloc] initWithRootViewController:hotFundsVC];
    hotFundsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"热门"
                                                           image:[UIImage systemImageNamed:@"flame"]
                                                   selectedImage:[UIImage systemImageNamed:@"flame.fill"]];

    // 基金公司
    FMFundCompaniesViewController *companiesVC = [[FMFundCompaniesViewController alloc] init];
    UINavigationController *companiesNav = [[UINavigationController alloc] initWithRootViewController:companiesVC];
    companiesNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"基金"
                                                            image:[UIImage systemImageNamed:@"building.2"]
                                                    selectedImage:[UIImage systemImageNamed:@"building.2.fill"]];

    // 设置
    FMSettingsViewController *settingsVC = [[FMSettingsViewController alloc] init];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置"
                                                           image:[UIImage systemImageNamed:@"gearshape"]
                                                   selectedImage:[UIImage systemImageNamed:@"gearshape.fill"]];

    self.viewControllers = @[myFundsNav, hotFundsNav, companiesNav, settingsNav];
}

- (void)setupAppearance {
    // 根据设置决定主题
    BOOL followSystem = [FMSettingsManager sharedManager].followSystemAppearance;

    if (followSystem) {
        // 跟随系统
        if (@available(iOS 13.0, *)) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
        }
    } else {
        // 强制浅色模式
        if (@available(iOS 13.0, *)) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
    }

    // 设置TabBar外观
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor systemBackgroundColor];

        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    }

    // 设置NavigationBar外观
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navAppearance = [[UINavigationBarAppearance alloc] init];
        [navAppearance configureWithOpaqueBackground];
        navAppearance.backgroundColor = [UIColor systemBackgroundColor];

        [[UINavigationBar appearance] setStandardAppearance:navAppearance];
        [[UINavigationBar appearance] setScrollEdgeAppearance:navAppearance];
    }
}

#pragma mark - Theme Change

- (void)appearanceSettingDidChange {
    // 主题变更时刷新界面
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.view.window.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupAppearance];
}

@end
