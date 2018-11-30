//
//  Command.m
//  DesignPatten
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import "Command.h"
#import "CommandManager.h"

@implementation Command
- (void)execute{
    
    //override to subclass;
    
    [self done];
}

- (void)cancel{
    
    self.completion = nil;
}

- (void)done{
    __weak __typeof(self)wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (wself.completion) {
            wself.completion(wself);
        }
        
        //释放
        wself.completion = nil;
        
        [[CommandManager sharedInstance].arrayCommands removeObject:wself];
    });
}

@end
