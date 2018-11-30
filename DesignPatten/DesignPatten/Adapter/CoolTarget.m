//
//  CoolTarge.m
//  DesignPatten
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import "CoolTarget.h"

@implementation CoolTarget

- (void)request{
    // 额外处理
    NSLog(@"额外处理111111");
    
    [self.target operation];
    
    NSLog(@"额外处理2222222");
    
    // 额外处理
}
@end
