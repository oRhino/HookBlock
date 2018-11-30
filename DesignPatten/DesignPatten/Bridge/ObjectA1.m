//
//  ObjectA1.m
//  DesignPatten
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import "ObjectA1.h"

@implementation ObjectA1

- (void)handle{
    // before 业务逻辑操作
    NSLog(@"before 业务逻辑操作");
    
    [super handle];
    
    NSLog(@"after 业务逻辑操作");
    // after 业务逻辑操作

}
@end
