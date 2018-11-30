//
//  CommonSuperFind.h
//  Arithmetic
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface CommonSuperFind : NSObject

// 查找两个视图的共同父视图
- (NSArray<UIView *> *)findCommonSuperView:(UIView *)view other:(UIView *)viewOther;


@end

NS_ASSUME_NONNULL_END
