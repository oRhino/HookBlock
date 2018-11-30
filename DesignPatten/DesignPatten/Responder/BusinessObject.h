//
//  BusinessObject.h
//  DesignPatten
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class BusinessObject;
typedef void (^CompletionBlock)(BOOL handled);
typedef void (^ResultBlock)(BusinessObject *handler,BOOL handled);


@interface BusinessObject : NSObject
//** 下一个响应者（响应链构成的关键） */
@property(nonatomic, strong) BusinessObject *nextBusiness;
//响应者的处理方法
- (void)handle:(ResultBlock )result;
//各个业务在该方法当中做实际业务处理
- (void)handleBusiness:(CompletionBlock )completion;

@end

NS_ASSUME_NONNULL_END
