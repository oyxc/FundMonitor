//
//  UIWindow+DCLog.m
//  NCBWallet
//
//  Created by HaiJun on 2021/7/9.
//

#import "UIWindow+DCLog.h"
#import "DCLog.h"

@implementation UIWindow (DCLog)

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventSubtypeMotionShake) {
        [DCLog changeVisible];
    }
}

@end
