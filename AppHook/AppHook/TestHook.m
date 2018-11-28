//
//  TestHook.m
//  AppHook
//
//  Created by Rhino on 2018/11/28.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import "TestHook.h"
#import <objc/message.h>
#import "fishhook.h"


/*
如何才能防护住？ 删除他的防护？ 在它防护之前先加载？修改MachO文件？
通过动态共享库，直接hook load();
https://github.com/Polidea/ios-class-guard
https://github.com/HikariObfuscator/Hikari
*/


@implementation TestHook

//保留原来函数h指针
void (*oldFunc)(Method a,Method b);

//函数原型
void my_method_exchangeImplementations(Method a,Method b){
    
    NSLog(@"exchange外部hook攻击~@");
    
}

IMP (*old_setImplementation)(Method a,IMP imp);

IMP fish_setImplementation(Method a,IMP imp){
    NSLog(@"setImp外部hook攻击~@");
    return imp;
}

IMP (*old_getImplementation)(Method  m);

IMP fish_getImplementation(Method  m){
     NSLog(@"getImp外部hook攻击~@");
    return old_getImplementation(m);
}


+ (void)load{
    
    NSLog(@"动态注入成功~");
    
    //1.基本防护 method_exchangeImplementations
    rebind_symbols((struct rebinding[3]){
        {"method_exchangeImplementations",my_method_exchangeImplementations,(void *)&oldFunc},{"method_setImplementation",fish_setImplementation,(void *)&old_setImplementation},
        {"method_getImplementation",fish_getImplementation,(void *)&old_getImplementation}
    }, 3);

    //2.用MonkeyDev logos还是可以Hook的
    //底层调用objc的runtime和fishhook来替换系统或者目标应用的函数,其实它能hook住是调用了method_setImplementation和method_getImplementation 所以防护的代码再加上这2个就可以
    
    
    //hook1:
//    Method method_old = class_getInstanceMethod(objc_getClass("ViewController"), NSSelectorFromString(@"buttonClick:"));
//    Method method_new = class_getInstanceMethod(self, @selector(hook:));
//    method_exchangeImplementations(method_new, method_old);
    
    
    //hook2:
    Method method_old = class_getInstanceMethod(objc_getClass("ViewController"), NSSelectorFromString(@"buttonClick:"));
    Method method_new = class_getInstanceMethod(self, @selector(hook:));
    IMP Imp = method_getImplementation(method_new);
    method_setImplementation(method_old, Imp);
    
}

- (void)hook:(id)send{
    NSLog(@"____想买 ?  没门!!!");
}


@end
