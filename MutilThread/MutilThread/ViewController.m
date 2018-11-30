//
//  ViewController.m
//  MutilThread
//
//  Created by Rhino on 2018/11/30.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
//    [self test1];
    
//    [self test2];
    
}

#pragma mark - 1
//死锁
/*
 主线程      主队列
| 任务1
| sync -->  任务2
| 任务3
 
 分析:同步执行 + 主队列会卡死当前线程,dispatch_sync不会开辟新的线程，在当前线程执行，并且立马在当前线程同步执行任务。主队列（也是一个串行队列）。主队列中有两个任务，分别是viewDidLoad和任务2。任务3执行完，才相当于viewDidLoad任务执行完毕，而任务3要等任务2执行完才能执行，但是任务2要等viewDidLoad执行完才能执行，所以造成相互等待。
 
 结论：使用sync函数往当前串行队列中添加任务，会卡住当前的串行队列（产生死锁）
*/
- (void)test1{
    
    NSLog(@"执行任务1");
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        NSLog(@"执行任务2");
    });
    NSLog(@"执行任务3");
    
}
#pragma mark - 2
- (void)test2{
    NSLog(@"___Question2___");
    dispatch_queue_t global = dispatch_get_global_queue(0, 0);
    dispatch_async(global, ^{
        NSLog(@"1");
        //本质是在当前线程的runloop 的default mode开启一个定时器,当定时器开始时,执行这个selector
        //因为当前为子线程,子线程的runloop默认是不开启的,这个方法得不到执行
        [self performSelector:@selector(performDelay) withObject:nil afterDelay:2];
        
        //performSelector内部会将定时器添加到runloop中,runloop已经有定时器了,所以这里不需要再添加一个端口了
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
        NSLog(@"2");
    });
    NSLog(@"3");
}

- (void)performDelay{
    NSLog(@"____%s____",__func__);
}


#pragma mark - 3
/*
 分析：因为创建一个线程，默认没有启动runloop，所以线程一启动执行完后就退出了。

线程的任务一旦执行完毕，生命周期就结束，无法再使用
保住线程的命为什么要使用runloop，用强指针不就可以了么？
准确来说，使用runloop是为了让线程保持激活状态。
 */

/** 开启一个新线程,然后执行任务 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1");
        
        //解决方案:开始runloop,线程保活
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
    }];
    [thread start];
    
    //线程执行完就不存在了 会造成崩溃
    /***
     Terminating app due to uncaught exception 'NSDestinationInvalidException', reason: '*** -[ViewController performSelector:onThread:withObject:waitUntilDone:modes:]: target thread exited while waiting for the perform'
     ***/
    [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:YES];
}

- (void)test{
    
    NSLog(@"!~~~!~~~!");
}

- (void)test4{
    
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("my_queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 添加异步任务
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务1-%@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务2-%@", [NSThread currentThread]);
        }
    });
    
    // 等前面的任务执行完毕后，会自动执行这个任务
    //    dispatch_group_notify(group, queue, ^{
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            for (int i = 0; i < 5; i++) {
    //                NSLog(@"任务3-%@", [NSThread currentThread]);
    //            }
    //        });
    //    });
    
    //    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    //        for (int i = 0; i < 5; i++) {
    //            NSLog(@"任务3-%@", [NSThread currentThread]);
    //        }
    //    });
    
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务3-%@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务4-%@", [NSThread currentThread]);
        }
    });
    
    
}
/**
1.你理解的多线程？
Grand Central Dispatch(GCD) 是 Apple 开发的一个多核编程的较新的解决方法。它主要用于优化应用程序以支持多核处理器以及其他对称多处理系统。它是一个在线程池模式的基础上执行的并发任务。在 Mac OS X 10.6 雪豹中首次推出，也可在 iOS 4 及以上版本使用。

2.iOS的多线程方案有哪几种？你更倾向于哪一种？
image.png
3.你在项目中用过 GCD 吗？
必须有用到啊

4.GCD 的队列类型
GCD的队列可以分为2大类型

并发队列（Concurrent Dispatch Queue）
可以让多个任务并发（同时）执行（自动开启多个线程同时执行任务）
并发功能只有在异步（dispatch_async）函数下才有效

串行队列（Serial Dispatch Queue）
让任务一个接着一个地执行（一个任务执行完毕后，再执行下一个任务）

5.说一下 OperationQueue 和 GCD 的区别，以及各自的优势
6.线程安全的处理手段有哪些？
查看我的另外一篇文章 iOS-底层原理(23)-多线程的安全隐患+11种同步解决方案

7.OC你了解的锁有哪些？在你回答基础上进行二次提问；
查看我的另外一篇文章 iOS-底层原理(23)-多线程的安全隐患+11种同步解决方案

追问一：自旋和互斥对比？
什么情况使用自旋锁比较划算？

预计线程等待锁的时间很短
加锁的代码（临界区）经常被调用，但竞争情况很少发生
CPU资源不紧张
多核处理器
什么情况使用互斥锁比较划算？

预计线程等待锁的时间较长
单核处理器
临界区有IO操作
临界区代码复杂或者循环量大
临界区竞争非常激烈
追问二：使用以上锁需要注意哪些？
追问三：用C/OC/C++，任选其一，实现自旋或互斥？口述即可！

*/

@end
