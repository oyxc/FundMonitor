//
//  FMFundCompany.h
//  FundMonitor
//
//  基金公司模型
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMFundCompany : NSObject

@property (nonatomic, copy) NSString *companyId;    // 公司ID
@property (nonatomic, copy) NSString *companyName;  // 公司名称

+ (instancetype)companyWithId:(NSString *)companyId name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
