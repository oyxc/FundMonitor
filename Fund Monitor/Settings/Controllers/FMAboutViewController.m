//
//  FMAboutViewController.m
//  FundMonitor
//
//  关于页面实现
//

#import "FMAboutViewController.h"

@interface FMAboutViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation FMAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"关于";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
}

- (void)setupUI {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];

    CGFloat padding = 20;
    CGFloat yOffset = 40;
    CGFloat width = self.view.bounds.size.width - 2 * padding;

    // 应用名称
    UILabel *appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, width, 40)];
    appNameLabel.text = @"Fund Monitor";
    appNameLabel.font = [UIFont boldSystemFontOfSize:28];
    appNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:appNameLabel];
    yOffset += 50;

    // 版本号
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, width, 20)];
    versionLabel.text = [NSString stringWithFormat:@"版本 %@", version ?: @"1.0"];
    versionLabel.font = [UIFont systemFontOfSize:14];
    versionLabel.textColor = [UIColor grayColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:versionLabel];
    yOffset += 40;

    // 分隔线
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(padding, yOffset, width, 1)];
    separator.backgroundColor = [UIColor separatorColor];
    [self.scrollView addSubview:separator];
    yOffset += 30;

    // 简介内容
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, yOffset, width, 0)];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.font = [UIFont systemFontOfSize:16];
    self.contentLabel.textColor = [UIColor labelColor];

    NSString *content = @"Fund Monitor 是一款简洁的基金监控工具。\n\n主要功能：\n• 自选基金管理\n• 实时估值查询\n• 分组管理\n• 热门基金推荐\n• 自动刷新\n\n© 2024 Fund Monitor";

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    paragraphStyle.alignment = NSTextAlignmentLeft;

    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content
                                                                         attributes:@{
        NSParagraphStyleAttributeName: paragraphStyle,
        NSFontAttributeName: [UIFont systemFontOfSize:16]
    }];

    self.contentLabel.attributedText = attributedText;

    // 计算文本高度
    CGSize size = [self.contentLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    self.contentLabel.frame = CGRectMake(padding, yOffset, width, size.height);
    [self.scrollView addSubview:self.contentLabel];
    yOffset += size.height + 40;

    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, yOffset);
}

@end
