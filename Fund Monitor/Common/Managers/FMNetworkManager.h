//
//  FMNetworkManager.h
//  FundMonitor
//
//  网络请求管理类 - 负责获取基金数据
//

#import <Foundation/Foundation.h>
#import "FMFund.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FMNetworkSuccessBlock)(id responseObject);
typedef void(^FMNetworkFailureBlock)(NSError *error);

@interface FMNetworkManager : NSObject

// 单例
+ (instancetype)sharedManager;

// 搜索基金（根据代码或名称）
- (void)searchFundWithKeyword:(NSString *)keyword
                      success:(FMNetworkSuccessBlock)success
                      failure:(FMNetworkFailureBlock)failure;

// 批量获取基金估值
- (void)fetchMultipleFundsEstimate:(NSArray<NSString *> *)fundCodes
                           success:(FMNetworkSuccessBlock)success
                           failure:(FMNetworkFailureBlock)failure;

// 获取热门基金列表
- (void)fetchHotFunds:(FMNetworkSuccessBlock)success
              failure:(FMNetworkFailureBlock)failure;

// 获取基金详细信息
- (void)fetchFundDetail:(NSString *)fundCode
                success:(FMNetworkSuccessBlock)success
                failure:(FMNetworkFailureBlock)failure;

// 获取基金历史净值数据
- (void)fetchFundHistoryData:(NSString *)fundCode
                    pageSize:(NSInteger)pageSize
                     success:(FMNetworkSuccessBlock)success
                     failure:(FMNetworkFailureBlock)failure;

// 获取全量基金
- (void)fetchAllFundWithSuccess:(FMNetworkSuccessBlock)success
                        failure:(FMNetworkFailureBlock)failure;

// 获取基金公司列表
- (void)fetchFundCompanies:(FMNetworkSuccessBlock)success
                   failure:(FMNetworkFailureBlock)failure;

// 获取热门基金销量排行（新接口）
- (void)fetchHotFundRanking:(NSString * _Nullable)fundType
                  companyId:(NSString * _Nullable)companyId
                  pageIndex:(NSInteger)pageIndex
                   pageSize:(NSInteger)pageSize
                    success:(FMNetworkSuccessBlock)success
                    failure:(FMNetworkFailureBlock)failure;

// 获取累计收益率走势数据（支持完整时间段）
// type: m=1月, q=3月, hy=6月, y=1年, try=3年, fiy=5年, sy=今年, se=成立来
- (void)fetchGrandTotalData:(NSString *)fundCode
                 indexCode:(NSString *)indexCode
                      type:(NSString *)type
                   success:(FMNetworkSuccessBlock)success
                   failure:(FMNetworkFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
