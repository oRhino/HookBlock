//
//  CoolTarge.h
//  DesignPatten
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Target.h"

NS_ASSUME_NONNULL_BEGIN


@interface CoolTarget : NSObject
//** 被适配对象 */
@property(nonatomic, strong) Target *target;

//对原有方法包装
- (void)request;

@end

NS_ASSUME_NONNULL_END
