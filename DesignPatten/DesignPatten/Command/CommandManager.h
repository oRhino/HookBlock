//
//  CommandManager.h
//  DesignPatten
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Command.h"

NS_ASSUME_NONNULL_BEGIN


@interface CommandManager : NSObject
// 命令管理容器
@property (nonatomic, strong) NSMutableArray <Command*> *arrayCommands;

// 命令管理者以单例方式呈现
+ (instancetype)sharedInstance;

// 执行命令
+ (void)executeCommand:(Command *)cmd completion:(CommandCompletionCallBack)completion;

// 取消命令
+ (void)cancelCommand:(Command *)cmd;

@end

NS_ASSUME_NONNULL_END
