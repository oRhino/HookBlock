//
//  BaseObjectA.h
//  DesignPatten
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObjectB.h"

NS_ASSUME_NONNULL_BEGIN


@interface BaseObjectA : NSObject
//** 桥接模式的核心实现 */
@property(nonatomic, strong) BaseObjectB *objB;
//获取数据
- (void)handle;
@end

NS_ASSUME_NONNULL_END
