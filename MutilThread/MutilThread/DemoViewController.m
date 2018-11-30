
//
//  DemoViewController.m
//  MutilThread
//
//  Created by Rhino on 2018/11/30.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import "DemoViewController.h"
#import "MJBaseDemo.h"
#import "OSSpinLockDemo.h"
#import "OSSpinLockDemo2.h"


@interface DemoViewController ()
@property (strong, nonatomic) MJBaseDemo *demo;

@end

@implementation DemoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    MJBaseDemo *demo = [[OSSpinLockDemo2 alloc] init];
    [demo ticketTest];
    [demo moneyTest];
    
    for (int i = 0; i < 10; i++) {
        [[[NSThread alloc] initWithTarget:self selector:@selector(test) object:nil] start];
    }
}

- (int)test
{
    int a = 10;
    int b = 20;
    
    NSLog(@"%p", self.demo);
    
    int c = a + b;
    return c;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
