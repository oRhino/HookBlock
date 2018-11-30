//
//  Command.h
//  DesignPatten
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Command;
typedef void(^CommandCompletionCallBack)(Command* cmd);

@interface Command : NSObject

@property (nonatomic, copy) CommandCompletionCallBack completion;

- (void)execute;
- (void)cancel;



@end

NS_ASSUME_NONNULL_END
