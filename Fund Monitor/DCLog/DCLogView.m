//
//  DCLogView.m
//  DCLogViewDemo
//
//  Created by DarielChen https://github.com/DarielChen/DCLog
//  Copyright © 2016年 DarielChen. All rights reserved.
//

#import "DCLogView.h"
#import "DCLog.h"

@interface DCLogView() <UITextFieldDelegate>

@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UIButton *copylogButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) NSInteger segmentIndex;

// 搜索功能相关属性
@property (nonatomic, strong) UIView *searchBarContainer;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UILabel *searchCountLabel;
@property (nonatomic, strong) NSMutableArray *searchRanges;
@property (nonatomic, assign) NSInteger currentHighlightIndex;
@property (nonatomic, strong) NSString *lastSearchText;
@property (nonatomic, assign) BOOL isViewVisible;

@end

@implementation DCLogView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    // 初始化搜索相关属性
    self.searchRanges = [NSMutableArray array];
    self.currentHighlightIndex = 0;
    self.lastSearchText = @"";
    self.isViewVisible = YES;  // 初始状态为可见，允许加载日志
    
    // 创建搜索栏容器
    self.searchBarContainer = [[UIView alloc] init];
    self.searchBarContainer.backgroundColor = [UIColor colorWithRed:39/255.0 green:40/255.0 blue:34/255.0 alpha:1.0];
    [self addSubview:self.searchBarContainer];
    
    // 创建搜索输入框
    self.searchTextField = [[UITextField alloc] init];
    self.searchTextField.backgroundColor = [UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.font = [UIFont systemFontOfSize:14.0];
    self.searchTextField.placeholder = @"输入关键字...";
    self.searchTextField.layer.cornerRadius = 4.0;
    self.searchTextField.layer.borderColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1.0].CGColor;
    self.searchTextField.layer.borderWidth = 1.0;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
    self.searchTextField.leftView = paddingView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.searchTextField setReturnKeyType:UIReturnKeySearch];
    self.searchTextField.delegate = self;  // 设置代理
    [self.searchBarContainer addSubview:self.searchTextField];
    
    // 创建搜索按钮
    self.searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.searchButton.layer.cornerRadius = 4.0f;
    self.searchButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(searchButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.searchButton.layer.borderWidth = 1.0f;
    self.searchButton.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    [self.searchBarContainer addSubview:self.searchButton];
    
    // 创建上一个按钮
    self.previousButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.previousButton.layer.cornerRadius = 4.0f;
    self.previousButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.previousButton setTitle:@"↑" forState:UIControlStateNormal];
    [self.previousButton addTarget:self action:@selector(previousHighlightClick) forControlEvents:UIControlEventTouchUpInside];
    self.previousButton.layer.borderWidth = 1.0f;
    self.previousButton.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    [self.searchBarContainer addSubview:self.previousButton];
    
    // 创建下一个按钮
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextButton.layer.cornerRadius = 4.0f;
    self.nextButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.nextButton setTitle:@"↓" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextHighlightClick) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.layer.borderWidth = 1.0f;
    self.nextButton.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    [self.searchBarContainer addSubview:self.nextButton];
    
    // 创建搜索计数标签
    self.searchCountLabel = [[UILabel alloc] init];
    self.searchCountLabel.textColor = [UIColor colorWithRed:100/255.0 green:200/255.0 blue:255/255.0 alpha:1.0];
    self.searchCountLabel.font = [UIFont systemFontOfSize:12.0];
    self.searchCountLabel.text = @"0/0";
    [self.searchBarContainer addSubview:self.searchCountLabel];
    
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.backgroundColor = [UIColor colorWithRed:39/255.0 green:40/255.0 blue:34/255.0 alpha:1.0];
    self.logTextView.textColor = [UIColor whiteColor];
    self.logTextView.font = [UIFont systemFontOfSize:14.0];
    self.logTextView.editable = NO;
    self.logTextView.layoutManager.allowsNonContiguousLayout = NO;
    self.logTextView.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.logTextView];
    
    NSArray *segmentArray = @[@"NSLog",@"Crash"];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:segmentArray];
    self.segmentControl.selectedSegmentIndex = 0;
    self.segmentIndex = 0;
    [self.segmentControl addTarget:self action:@selector(didClickSegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.segmentControl];
    
    self.copylogButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.copylogButton.layer.cornerRadius = 5.0f;
    self.copylogButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.copylogButton setTitle:@"copy" forState:UIControlStateNormal];
    [self.copylogButton addTarget:self action:@selector(copylogButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.copylogButton.layer.borderWidth = 1.0f;
    self.copylogButton.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    [self addSubview:self.copylogButton];
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.clearButton.layer.cornerRadius = 5.0f;
    self.clearButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.clearButton setTitle:@"clear" forState:UIControlStateNormal];
    [self.clearButton addTarget:self action:@selector(clearButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.clearButton.layer.borderWidth = 1.0f;
    self.clearButton.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    [self addSubview:self.clearButton];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.layer.cornerRadius = 5.0f;
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self.closeButton setTitle:@"touch close" forState:UIControlStateNormal];
    self.closeButton.layer.borderWidth = 1.0f;
    self.closeButton.layer.borderColor = [UIColor colorWithRed:12/255.0 green:95/255.0 blue:250/255.0 alpha:1.0].CGColor;
    [self.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
    
}

- (void)updateLog:(NSString *)logText {
    // 只在视图不可见时更新日志
    if (!self.isViewVisible) {
        return;
    }
    
    // 更新日志文本，但保留搜索高亮
    if (self.logTextView.contentSize.height <= (self.logTextView.contentOffset.y + CGRectGetHeight(self.bounds))) {
        self.logTextView.text = logText;
        [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.text.length, 1)];
    }else {
        self.logTextView.text = logText;
    }
    
    // 如果之前有搜索结果，重新高亮
    if (self.searchRanges.count > 0) {
        [self highlightCurrentResult];
    }
}

- (void)clearButtonClick {
    // 清除搜索相关的状态
    [self.searchRanges removeAllObjects];
    self.currentHighlightIndex = 0;
    self.searchTextField.text = @"";
    self.searchCountLabel.text = @"0/0";
    
    if (_CleanButtonIndexBlock) {
        _CleanButtonIndexBlock(self.segmentIndex);
    }
}

- (void)closeButtonClick {
    [DCLog changeVisible];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat top = iPhoneX ? 88 : 64;
    CGFloat safetop = iPhoneX ? 44 : 20;
    CGFloat centerY = safetop + (top - safetop)/2.0;
    
    // 搜索栏布局
    CGFloat searchBarHeight = 50;
    self.searchBarContainer.frame = CGRectMake(0, top, self.bounds.size.width, searchBarHeight);
    
    CGFloat searchbarMargin = 8;
    CGFloat searchbarPadding = 5;
    CGFloat buttonWidth = 35;
    CGFloat searchFieldHeight = 32;
    CGFloat searchFieldStartX = searchbarMargin;
    
    self.searchTextField.frame = CGRectMake(searchFieldStartX, searchbarPadding, self.bounds.size.width - searchFieldStartX - searchbarMargin - buttonWidth * 3 - searchbarPadding * 4 - 50 - searchbarPadding * 2, searchFieldHeight);
    
    self.searchButton.frame = CGRectMake(CGRectGetMaxX(self.searchTextField.frame) + searchbarPadding, searchbarPadding, 40, searchFieldHeight);
    
    self.previousButton.frame = CGRectMake(CGRectGetMaxX(self.searchButton.frame) + searchbarPadding, searchbarPadding, buttonWidth, searchFieldHeight);
    
    self.nextButton.frame = CGRectMake(CGRectGetMaxX(self.previousButton.frame) + searchbarPadding, searchbarPadding, buttonWidth, searchFieldHeight);
    
    self.searchCountLabel.frame = CGRectMake(CGRectGetMaxX(self.nextButton.frame) + searchbarPadding, searchbarPadding, 45, searchFieldHeight);
    self.searchCountLabel.textAlignment = NSTextAlignmentCenter;
    
    self.logTextView.frame = CGRectMake(0, top + searchBarHeight, self.bounds.size.width, self.bounds.size.height - top - searchBarHeight);
    
    self.segmentControl.frame = CGRectMake(16.0, safetop, 100.0, 30.0);
    self.segmentControl.center= CGPointMake(self.segmentControl.center.x, centerY);
    
    self.copylogButton.frame = CGRectMake(self.bounds.size.width-16-50, safetop, 50.0, 30.0);
    self.copylogButton.center = CGPointMake(self.copylogButton.center.x, centerY);
    
    self.clearButton.frame = CGRectMake(self.bounds.size.width-16-50 - 10 - 50, safetop, 50.0, 30.0);
    self.clearButton.center = CGPointMake(self.clearButton.center.x, centerY);
    
    self.closeButton.frame = CGRectMake(self.frame.size.width/2.0 - 50, safetop, 100, 30.0);
    self.closeButton.center = CGPointMake(self.closeButton.center.x, centerY);
}

- (void)copylogButtonClick {

    if (_CopyButtonIndexBlock) {
        _CopyButtonIndexBlock(self.segmentIndex,self.logTextView.text);
    }
}

- (void)didClickSegmentedControlAction:(UISegmentedControl *)control {
    if (_indexBlock) {
        _indexBlock(control.selectedSegmentIndex);
    }
    self.segmentIndex = control.selectedSegmentIndex;
}

#pragma mark - 搜索功能

- (void)searchButtonClick {
    NSString *searchText = [self.searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText.length == 0) {
        // 清除搜索
        [self.searchRanges removeAllObjects];
        self.currentHighlightIndex = 0;
        [self clearSearchHighlight];
        self.searchCountLabel.text = @"0/0";
        return;
    }
    
    [self performSearch:searchText];
}

- (void)performSearch:(NSString *)searchText {
    [self.searchRanges removeAllObjects];
    self.currentHighlightIndex = 0;
    self.lastSearchText = searchText;
    
    // 查找所有匹配的范围
    NSString *text = self.logTextView.text;
    
    // 检查文本是否为空
    if (text.length == 0) {
        self.searchCountLabel.text = @"0/0";
        return;
    }
    
    NSRange searchRange = NSMakeRange(0, text.length);
    NSRange foundRange;
    
    while (searchRange.location < text.length) {
        foundRange = [text rangeOfString:searchText options:NSCaseInsensitiveSearch range:searchRange];
        if (foundRange.location != NSNotFound) {
            [self.searchRanges addObject:[NSValue valueWithRange:foundRange]];
            searchRange = NSMakeRange(NSMaxRange(foundRange), text.length - NSMaxRange(foundRange));
        } else {
            break;
        }
    }
    
    // 更新计数标签和高亮
    if (self.searchRanges.count > 0) {
        self.searchCountLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.searchRanges.count];
        [self highlightCurrentResult];
    } else {
        self.searchCountLabel.text = @"0/0";
        [self clearSearchHighlight];
    }
}

- (void)highlightCurrentResult {
    if (self.searchRanges.count == 0) return;
    
    // 获取原始的文本（不是 attributedText）
    NSString *originalText = self.logTextView.text;
    
    // 如果 logTextView 已经有 attributedText，保持它的基础样式
    NSMutableAttributedString *attributedString;
    if (self.logTextView.attributedText && self.logTextView.attributedText.length > 0) {
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.logTextView.attributedText];
    } else {
        attributedString = [[NSMutableAttributedString alloc] initWithString:originalText];
    }
    
    // 为所有匹配的范围添加浅色背景
    for (NSValue *rangeValue in self.searchRanges) {
        NSRange range = rangeValue.rangeValue;
        [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:255/255.0 green:200/255.0 blue:0/255.0 alpha:0.4] range:range];
    }
    
    // 为当前的高亮添加深色背景
    NSValue *currentRangeValue = self.searchRanges[self.currentHighlightIndex];
    NSRange currentRange = currentRangeValue.rangeValue;
    [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:255/255.0 green:200/255.0 blue:0/255.0 alpha:0.9] range:currentRange];
    
    self.logTextView.attributedText = attributedString;
    
    // 滚动到当前结果
    [self.logTextView scrollRangeToVisible:currentRange];
    
    // 更新计数标签
    self.searchCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)(self.currentHighlightIndex + 1), (long)self.searchRanges.count];
}

- (void)previousHighlightClick {
    if (self.searchRanges.count == 0) return;
    
    self.currentHighlightIndex--;
    if (self.currentHighlightIndex < 0) {
        self.currentHighlightIndex = self.searchRanges.count - 1;
    }
    
    [self highlightCurrentResult];
}

- (void)nextHighlightClick {
    if (self.searchRanges.count == 0) return;
    
    self.currentHighlightIndex++;
    if (self.currentHighlightIndex >= self.searchRanges.count) {
        self.currentHighlightIndex = 0;
    }
    
    [self highlightCurrentResult];
}

- (void)clearSearchHighlight {
    // 恢复原始文本颜色和背景
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.logTextView.text];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, self.logTextView.text.length)];
    [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:39/255.0 green:40/255.0 blue:34/255.0 alpha:1.0] range:NSMakeRange(0, self.logTextView.text.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, self.logTextView.text.length)];
    
    self.logTextView.attributedText = attributedString;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.searchTextField) {
        // 点击键盘的 Search 按钮时执行搜索
        [self searchButtonClick];
        // 隐藏键盘
        [self.searchTextField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Visibility Control

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    // 视图将要添加到父视图时（显示）
    if (newSuperview != nil) {
        self.isViewVisible = YES;
    } else {
        // 视图将要从父视图移除时（隐藏）
        self.isViewVisible = NO;
    }
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
