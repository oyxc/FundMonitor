//
//  FMImportFundViewController.m
//  FundMonitor
//
//  导入基金持仓页面
//

#import "FMImportFundViewController.h"
#import "FMImportConfirmViewController.h"
#import "FMNetworkManager.h"
#import "FMDataManager.h"
#import "FMFund.h"
#import <Vision/Vision.h>
#import <Photos/Photos.h>

@interface FMImportFundViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton *selectImageButton;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) NSArray *allData;
@property (nonatomic, strong) NSArray<FMFund *> *importedFunds;  // 导入的基金列表

@end

@implementation FMImportFundViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"导入持仓";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupUI];
    
    [self requestAllFund:^{}];
}

- (void)setupUI {
    // 选择图片按钮
    self.selectImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.selectImageButton setTitle:@"去相册选择截图" forState:UIControlStateNormal];
    self.selectImageButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.selectImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.selectImageButton.backgroundColor = [UIColor systemBlueColor];
    self.selectImageButton.layer.cornerRadius = 8;
    [self.selectImageButton addTarget:self action:@selector(selectImageAction) forControlEvents:UIControlEventTouchUpInside];
    self.selectImageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.selectImageButton];

    // 图片预览
    self.previewImageView = [[UIImageView alloc] init];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.previewImageView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.previewImageView.layer.cornerRadius = 8;
    self.previewImageView.clipsToBounds = YES;
    self.previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.previewImageView];

    // 识别结果显示
    self.resultTextView = [[UITextView alloc] init];
    self.resultTextView.font = [UIFont systemFontOfSize:14];
    self.resultTextView.textColor = [UIColor labelColor];
    self.resultTextView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.resultTextView.layer.cornerRadius = 8;
    self.resultTextView.editable = NO;
    self.resultTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.resultTextView];

    // 加载指示器
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loadingView];

    // 布局
    [NSLayoutConstraint activateConstraints:@[
        // 选择图片按钮
        [self.selectImageButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.selectImageButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:40],
        [self.selectImageButton.widthAnchor constraintEqualToConstant:200],
        [self.selectImageButton.heightAnchor constraintEqualToConstant:50],

        // 图片预览
        [self.previewImageView.topAnchor constraintEqualToAnchor:self.selectImageButton.bottomAnchor constant:20],
        [self.previewImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.previewImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.previewImageView.heightAnchor constraintEqualToConstant:200],

        // 识别结果
        [self.resultTextView.topAnchor constraintEqualToAnchor:self.previewImageView.bottomAnchor constant:20],
        [self.resultTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.resultTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.resultTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],

        // 加载指示器
        [self.loadingView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)selectImageAction {
    // 检查相册权限
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [self presentImagePicker];
                } else {
                    [self showAlertWithMessage:@"需要相册权限才能选择图片"];
                }
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        [self presentImagePicker];
    } else {
        [self showAlertWithMessage:@"请在设置中开启相册权限"];
    }
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)presentImagePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.previewImageView.image = image;
        [self recognizeTextInImage:image];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - OCR Recognition

- (void)recognizeTextInImage:(UIImage *)image {
    [self.loadingView startAnimating];
    self.resultTextView.text = @"正在识别...";

    // 创建 Vision 请求
    VNRecognizeTextRequest *request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopAnimating];

            if (error) {
                self.resultTextView.text = [NSString stringWithFormat:@"识别失败: %@", error.localizedDescription];
                return;
            }

            [self processRecognitionResults:request.results];
        });
    }];

    // 设置识别语言（支持中文和英文）
    request.recognitionLanguages = @[@"zh-Hans", @"en-US"];
    request.recognitionLevel = VNRequestTextRecognitionLevelAccurate;

    // 执行识别
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        [handler performRequests:@[request] error:&error];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingView stopAnimating];
                self.resultTextView.text = [NSString stringWithFormat:@"识别失败: %@", error.localizedDescription];
            });
        }
    });
}

- (void)processRecognitionResults:(NSArray<VNRecognizedTextObservation *> *)results {
    NSMutableString *allText = [NSMutableString string];
    NSMutableArray *fundInfos = [NSMutableArray array];

    // 按照 Y 坐标排序（从上到下），Vision 坐标系原点在左下角，所以 Y 值越大越靠上
    NSArray *sortedResults = [results sortedArrayUsingComparator:^NSComparisonResult(VNRecognizedTextObservation *obj1, VNRecognizedTextObservation *obj2) {
        CGFloat y1 = obj1.boundingBox.origin.y;
        CGFloat y2 = obj2.boundingBox.origin.y;

        // 定义一个容差值，用于判断是否在同一行（0.01 表示 1% 的高度差）
        CGFloat tolerance = 0.01;
        
        // 如果 Y 坐标差异小于容差，认为在同一行，按 X 坐标排序
        if (fabs(y1 - y2) < tolerance) {
            CGFloat x1 = obj1.boundingBox.origin.x;
            CGFloat x2 = obj2.boundingBox.origin.x;
            if (x1 < x2) {
                return NSOrderedAscending;  // x1 在左边
            } else if (x1 > x2) {
                return NSOrderedDescending; // x2 在左边
            }
            return NSOrderedSame;
        }

        // Y 值越大越靠上，所以降序排列
        if (y1 > y2) {
            return NSOrderedAscending;  // y1 更靠上
        } else {
            return NSOrderedDescending; // y2 更靠上
        }
    }];

    // 提取所有识别的文本，按行输出
    for (VNRecognizedTextObservation *observation in sortedResults) {
        VNRecognizedText *topCandidate = [observation topCandidates:1].firstObject;
        if (topCandidate) {
            [allText appendFormat:@"%@_", topCandidate.string];
            NSLog(@"%@,%f",topCandidate.string,observation.boundingBox.origin.y);
        }
    }

    // 解析基金信息
    NSString *newText = [allText stringByReplacingOccurrencesOfString:@"," withString:@""];
    newText = [newText stringByReplacingOccurrencesOfString:@"，" withString:@""];
    newText = [newText stringByReplacingOccurrencesOfString:@"._" withString:@"_"];
    newText = [newText stringByReplacingOccurrencesOfString:@"%_" withString:@"%%_"];
    NSRange rangeRate = [newText rangeOfString:@"_持有收益/率_"];
    if (rangeRate.length) {
        newText = [newText substringFromIndex:rangeRate.location + rangeRate.length];
    }
    
    NSArray *lines = [newText componentsSeparatedByString:@"%_"];
    NSLog(@"trimmedLine:%ld -------------------------------------------------------------",lines.count);
    for (NSString *line in lines) {
        NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedLine.length == 0) continue;
        if (![trimmedLine hasSuffix:@"%"]) continue;
        NSArray *items = [trimmedLine componentsSeparatedByString:@"_"];
        if (items.count < 5) continue;
        NSLog(@"%@",trimmedLine);
        
        //读取有效数据
        NSString *name; //基金名称
        NSString *holdAmount; //持有金额
        NSString *profit; //持有收益
        NSString *profitRate = items.lastObject; //收益率
        
        NSInteger index = 1;
        for (NSInteger i = 0; i < items.count; ++i) {
            NSString *rowString = items[i];
            if (holdAmount == nil) {
                //判断是否持有金额
                NSRegularExpression *amountRegex = [NSRegularExpression regularExpressionWithPattern:@"[+-]?\\d+\\.\\d{2}" options:0 error:nil];
                NSArray *amountMatches = [amountRegex matchesInString:rowString options:0 range:NSMakeRange(0, rowString.length)];
                if (amountMatches.count > 0) {
                    //持有金额
                    index = i;
                    break;
                }
            }
        }
        name = items[index-1];
        profit = [self checkAmountValue:items[index+1]];
        holdAmount = [self checkAmountValue:items[index]];
        holdAmount = [NSString stringWithFormat:@"%.2f",holdAmount.doubleValue - profit.doubleValue];
        if (items.count > index+4) {
            NSString *subName = items[index+2];
            if (![subName hasPrefix:@"金选 "] && ![subName isEqualToString:@"定投"]) {
                name = [NSString stringWithFormat:@"%@%@",name,subName];
            }
        }
        
        NSDictionary *currentFund = @{@"name": name?:@"",
                                      @"holdAmount": holdAmount?:@"",
                                      @"profit": profit?:@"",
                                      @"profitRate": profitRate?:@"",};
        
        [fundInfos addObject:currentFund];
    }

    // 显示结果
    self.resultTextView.text = newText;
    NSLog(@"list -------------------------------------------------------------");
    NSLog(@"list:\n %@",fundInfos);

    NSLog(@"result -------------------------------------------------------------");
    NSLog(@"result:\n %@",newText);
    
    __weak typeof(self) weakSelf = self;
    
    //获取基金代码
    [self requestAllFund:^{
        [weakSelf getFundCodeByfundList:fundInfos];
    }];
}

// 移除
- (NSString *)checkAmountValue:(NSString *)amount
{
    // 从倒数第3位之前的所有点
    return [amount stringByReplacingOccurrencesOfString:@"." withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, amount.length - 3)];
}

- (void)getFundCodeByfundList:(NSArray *)funds
{
    NSMutableArray *fundList = [NSMutableArray array];
    for (NSDictionary *dic in funds) {
        NSString *name = dic[@"name"];
        if (name == nil || name.length == 0) continue;
        NSString *suffix = [name substringFromIndex:name.length-1];
        NSArray *infos = [self fundCodeWithName:name suffix:suffix];
        if (infos) {
            NSMutableDictionary *newDic = [dic mutableCopy];
            newDic[@"code"] = infos.firstObject?:@"";
            [fundList addObject:newDic];
            continue;
        }
    }
    
    //获取基金数据
    [self requestInfoWithfunds:fundList];
}

- (NSArray *)fundCodeWithName:(NSString *)name suffix:(NSString *)suffix
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SUBQUERY(SELF, $item, $item CONTAINS[cd] %@).@count > 0", name];
    
    NSArray *filtered = [self.allData filteredArrayUsingPredicate:predicate];
    
    if (filtered.count == 1) {
        return filtered.firstObject;
    }
    if (filtered.count > 1) {
        for (NSArray *item in filtered) {
            NSString *name = item.lastObject;
            if ([name hasSuffix:suffix] && ![name containsString:@"美元"]) {
                return item;
            }
        }
        return nil;
    }
    NSString *subName = [name substringToIndex:name.length-1];
    return [self fundCodeWithName:subName suffix:suffix];
}

- (void)requestInfoWithfunds:(NSArray *)funds
{
    // 批量获取基金估值
    NSMutableArray *fundModels = [NSMutableArray array];
    
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"create group time:%@",NSDate.date);
    
    for (NSDictionary *dic in funds) {
        NSString *code = dic[@"code"];
        NSString *name = dic[@"name"];
        NSString *holdAmount = dic[@"holdAmount"];
        NSString *profit = dic[@"profit"];
        NSString *profitRate = dic[@"profitRate"];
        
        dispatch_group_enter(group);
        NSLog(@"enter group name:%@",name);
        
        // 搜索基金
        [[FMNetworkManager sharedManager] searchFundWithKeyword:code success:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                // 取第一个数据
                FMFund *fund = [(NSArray *)responseObject firstObject];
                if (self.groupId && holdAmount && holdAmount.length > 0) {
                    fund.holdAmountByGroup[self.groupId] = dic[@"holdAmount"];
                }
                if (self.groupId && profit && profit.length > 0) {
                    fund.holdProfitByGroup[self.groupId] = dic[@"profit"];
                }
                if (self.groupId && profitRate && profitRate.length > 0) {
                    fund.holdProfitRateByGroup[self.groupId] = dic[@"profitRate"];
                }
                if (fund.latestValue && [fund.latestValue doubleValue] > 0) {
                    double latestValue = [fund.latestValue doubleValue];
                    double profitRateValue = profitRate.doubleValue / 100;
                    // 持仓净值 = 最新净值 / (1 + 收益率)
                    double holdNetValue = latestValue / (1 + profitRateValue);
                    [fund setHoldNetValue:@(holdNetValue) forGroup:self.groupId];
                }
                [fundModels addObject:fund];
            }
            dispatch_group_leave(group);
            NSLog(@"leave group name:%@",name);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
            NSLog(@"leave group name:%@",name);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"notify group time:%@",NSDate.date);

        // 保存导入的基金列表
        self.importedFunds = [fundModels copy];

        // 跳转到确认页面
        [self showResult];
    });
}

- (void)showResult {
    if (!self.importedFunds || self.importedFunds.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"未识别到有效的基金信息"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    // 跳转到确认页面
    FMImportConfirmViewController *confirmVC = [[FMImportConfirmViewController alloc] init];
    confirmVC.fundModels = self.importedFunds;
    confirmVC.groupId = self.groupId;
    [self.navigationController pushViewController:confirmVC animated:YES];
}

- (void)requestAllFund:(dispatch_block_t)finish
{
    if (self.allData) {
        if (finish) {
            finish();
        }
        return;
    }
    // 搜索基金
    [[FMNetworkManager sharedManager] fetchAllFundWithSuccess:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            self.allData = responseObject;
        }
        if (finish) {
            finish();
        }
    } failure:^(NSError *error) {
        if (finish) {
            finish();
        }
    }];
}

@end
