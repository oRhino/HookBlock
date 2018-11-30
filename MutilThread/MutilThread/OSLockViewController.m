//
//  OSLockViewController.m
//  MutilThread
//
//  Created by Rhino on 2018/11/30.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import "OSLockViewController.h"
#import <libkern/OSAtomic.h>
#import <os/lock.h>

@interface OSLockViewController ()

@property (assign, nonatomic) int money;
@property (assign, nonatomic) int ticketsCount;
@property (assign, nonatomic) OSSpinLock lock;
@property (assign, nonatomic) OSSpinLock lock1;


@end

@implementation OSLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    os_unfair_lock
    // 初始化锁
    self.lock = OS_SPINLOCK_INIT;
    self.lock1 = OS_SPINLOCK_INIT;
    
    [self ticketTest];
    [self moneyTest];
}

/**
 存钱、取钱演示
 */
- (void)moneyTest
{
    self.money = 100;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++) {
            [self saveMoney];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++) {
            [self drawMoney];
        }
    });
}

/**
 存钱
 */
- (void)saveMoney
{
    // 加锁
    OSSpinLockLock(&_lock1);
    
    int oldMoney = self.money;
    sleep(.2);
    oldMoney += 50;
    self.money = oldMoney;
    
    NSLog(@"存50，还剩%d元 - %@", oldMoney, [NSThread currentThread]);
    
    // 解锁
    OSSpinLockUnlock(&_lock1);
}

/**
 取钱
 */
- (void)drawMoney
{
    // 加锁
    OSSpinLockLock(&_lock1);
    
    int oldMoney = self.money;
    sleep(.2);
    oldMoney -= 20;
    self.money = oldMoney;
    
    NSLog(@"取20，还剩%d元 - %@", oldMoney, [NSThread currentThread]);
    // 解锁
    OSSpinLockUnlock(&_lock1);
}

/*
 thread1：优先级比较高
 
 thread2：优先级比较低
 
 thread3
 
 线程的调度，10ms
 
 时间片轮转调度算法（进程、线程）
 线程优先级
 */

/**
 卖1张票
 */
- (void)saleTicket
{
    //    if (OSSpinLockTry(&_lock)) {
    //        int oldTicketsCount = self.ticketsCount;
    //        sleep(.2);
    //        oldTicketsCount--;
    //        self.ticketsCount = oldTicketsCount;
    //        NSLog(@"还剩%d张票 - %@", oldTicketsCount, [NSThread currentThread]);
    //
    //        OSSpinLockUnlock(&_lock);
    //    }
    
    // 加锁
    OSSpinLockLock(&_lock);
    
    int oldTicketsCount = self.ticketsCount;
    sleep(.2);
    oldTicketsCount--;
    self.ticketsCount = oldTicketsCount;
    NSLog(@"还剩%d张票 - %@", oldTicketsCount, [NSThread currentThread]);
    
    // 解锁
    OSSpinLockUnlock(&_lock);
}

/**
 卖票演示
 */
- (void)ticketTest
{
    self.ticketsCount = 15;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
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
