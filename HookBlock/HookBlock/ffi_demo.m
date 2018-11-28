//
//  ffi_demo.c
//  BlockTest
//
//  Created by Leo on 2018/7/10.
//  Copyright © 2018年 culeo. All rights reserved.
//

#include "ffi_demo.h"
#import <ffi/ffi.h>
#import <sys/mman.h>
#import <stdlib.h>
#import <Foundation/Foundation.h>

int fun1 (int a, int b) {
    NSLog(@"%s",__func__);
    return a + b;
}

int fun2 (int a, int b) {
    NSLog(@"%s",__func__);
    return 2 * a + b;
}
//当我们在运行时动态调用一个函数时，自己要先将相应栈和寄存器状态准备好，然后生成相应的汇编指令。这也正是libffi所做的

//函数实体
void ffi_function(ffi_cif *cif, void *ret, void **args, void *userdata) {
    NSLog(@"%s",__func__);
    int x = *((int *)args[0]);
    int y = *((int *)args[1]);
    //调用原函数
    ffi_call(cif, (void (*)(void))userdata,  ret, args);
    NSLog(@"2 * %d + %d = %d", x, y, *(int *)ret);
};

void ffi_demo_main(void)
{
    //形参类型
    ffi_type **types;
    types = malloc(sizeof(ffi_type *) * 2);
    types[0] = &ffi_type_sint;
    types[1] = &ffi_type_sint;
    
    //返回值
    ffi_type *retType = &ffi_type_sint;
    
    //实参
    void **args = malloc(sizeof(void *) * 2);
    int x = 1, y = 2;
    args[0] = &x;
    args[1] = &y;
    
    
    int ret = 0;
    
    ffi_cif cif;
    // 生成模板
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 2, retType, types);
    // 动态调用fun1
    ffi_call(&cif, (void (*)(void))fun1,  &ret, args);
    
    NSLog(@"%d",ret);
    
//    头文件：#include <unistd.h>    #include <sys/mman.h>
//    定义函数：void *mmap(void *start, size_t length, int prot, int flags, int fd, off_t offsize);
//    函数说明：mmap()用来将某个文件内容映射到内存中，对该内存区域的存取即是直接对该文件内容的读写。
    
    //生成ffi_closure
    ffi_closure *closure = mmap(NULL, sizeof(ffi_closure), PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    
    //生成函数原型
    ffi_status status = ffi_prep_closure(closure, &cif, ffi_function, fun2);
    if(status != FFI_OK) {
        NSLog(@"ffi_prep_closure returned %d", (int)status);
        //中止程序执行，直接从调用的地方跳出。
        abort();
    }
    //int mprotect(const void *start, size_t len, int prot);
    //mprotect()函数把自start开始的、长度为len的内存区的保护属性修改为prot指定的值。
    if(mprotect(closure, sizeof(closure), PROT_READ | PROT_EXEC) == -1) {
        //函数perror()用于抛出最近的一次系统错误信息
        perror("mprotect");
        abort();
    }
    ret = ( (int(*)(int , int) )closure)(1, 2);
    NSLog(@"ret %d", ret);
    
}
