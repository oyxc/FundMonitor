//
//  FMFundCompany.m
//  FundMonitor
//

#import "FMFundCompany.h"

@implementation FMFundCompany

+ (instancetype)companyWithId:(NSString *)companyId name:(NSString *)name {
    FMFundCompany *company = [[FMFundCompany alloc] init];
    company.companyId = companyId;
    company.companyName = name;
    return company;
}

@end
