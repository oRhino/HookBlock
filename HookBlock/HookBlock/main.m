//
//  main.m
//  HookBlock
//
//  Created by Rhino on 2018/11/26.
//  Copyright © 2018 Rhino. All rights reserved.
// https://opensource.apple.com/source/libclosure/libclosure-63/Block_private.h.auto.html

#import <Foundation/Foundation.h>
#import <ffi/ffi.h>
#import <sys/mman.h>
#import "fishhook.h"



// Values for Block_layout->flags to describe block objects
enum {
    N_BLOCK_DEALLOCATING =      (0x0001),  // runtime
    N_BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    N_BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    N_BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    N_BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    N_BLOCK_IS_GC =             (1 << 27), // runtime
    N_BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    N_BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    N_BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    N_BLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};


struct N_Block_descriptor{
    uintptr_t reserved;
    uintptr_t size;
    // requires BLOCK_HAS_COPY_DISPOSE
    void (*copy)(void *dst, const void *src);
    void (*dispose)(const void *);
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;     // contents depend on BLOCK_HAS_EXTENDED_LAYOUT
};


struct N_Block_layout {
    void *isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    void (*invoke)(void *, ...);
    struct N_Block_descriptor *descriptor;
    // imported variables
};

// MARK:- 第一题
void printHelloWord() {
    NSLog(@"Hello, World!");
}

//桥接 更改函数指针
void HookBlockToPrintHelloWorld(id block){
    

    struct N_Block_layout *imp = (__bridge struct N_Block_layout *)block;
    imp->invoke = (void *)printHelloWord;
}



NSMutableArray *g_allocations;

//获取方法签名
const char *getSignature(id block){
    
    struct N_Block_layout *Mblock = (__bridge struct N_Block_layout *)block;
    void *sign = Mblock->descriptor;
    
    sign += 2*(sizeof(unsigned long));
    
    if (Mblock->flags & N_BLOCK_HAS_COPY_DISPOSE) {
        sign += sizeof(void (*)(void *, const void *));
        sign += sizeof(void (*)(const void *));
    }
    const char *signature = (*(const char **)sign);
    return signature;
}

//获取函数指针
void *getFunstr(id block){
    struct N_Block_layout *Mblock = (__bridge struct N_Block_layout *)block;
    return Mblock->invoke;
}


//根据方法签名获取形参个数
int getArgumentCount(const char *str){
    //第一个是返回值,所以从-1开始
    int count = -1;
    while (str && *str) {
        ////获取编码类型的实际大小和对齐的大小。
        str = NSGetSizeAndAlignment(str, NULL, NULL);
        while (isdigit(*str)) {
            //如果是十进制数字,指针运算 ++操作
            str++;
        }
        count++;
    }
    return count;
}


void *
allocate(size_t howmuch) {
    NSMutableData *data = [NSMutableData dataWithLength:howmuch];
    [g_allocations addObject: data];
    return [data mutableBytes];
}


static ffi_type *
ffiArgumentForEncode(const char *str) {
    
#define SINT(type) do { \
if(str[0] == @encode(type)[0]) {\
if(sizeof(type) == 1) return &ffi_type_sint8; \
if(sizeof(type) == 2) return &ffi_type_sint16;\
if(sizeof(type) == 4) return &ffi_type_sint32;\
if(sizeof(type) == 8) return &ffi_type_sint64; \
NSLog(@"Unknown size for type %s", #type); \
abort();\
} \
} while(0)
    
#define UINT(type) do { \
if(str[0] == @encode(type)[0]) { \
if(sizeof(type) == 1) return &ffi_type_uint8; \
if(sizeof(type) == 2) return &ffi_type_uint16; \
if(sizeof(type) == 4) return &ffi_type_uint32; \
if(sizeof(type) == 8) return &ffi_type_uint64; \
NSLog(@"Unknown size for type %s", #type); \
abort(); \
} \
} while(0)
    
#define INT(type) do { \
SINT(type); \
UINT(unsigned type); \
} while(0)
    
#define COND(type, name) do { \
if(str[0] == @encode(type)[0]) return &ffi_type_ ## name; \
} while(0)
    
#define PTR(type) COND(type, pointer)
    
#define STRUCT(structType, ...) do { \
if(strncmp(str, @encode(structType), strlen(@encode(structType))) == 0) \
{ \
ffi_type *elementsLocal[] = { __VA_ARGS__, NULL }; \
ffi_type **elements = allocate(sizeof(elementsLocal)); \
memcpy(elements, elementsLocal, sizeof(elementsLocal)); \
\
ffi_type *structType = allocate(sizeof(*structType)); \
structType->type = FFI_TYPE_STRUCT; \
structType->elements = elements; \
return structType; \
} \
} while(0)
    
    SINT(_Bool);
    SINT(signed char);
    UINT(unsigned char);
    INT(short);
    INT(int);
    INT(long);
    INT(long long);
    
    PTR(id);
    PTR(Class);
    PTR(SEL);
    PTR(void *);
    PTR(char *);
    PTR(void (*)(void));
    
    COND(float, float);
    COND(double, double);
    
    COND(void, void);
    
    ffi_type *CGFloatFFI = sizeof(CGFloat) == sizeof(float) ? &ffi_type_float : &ffi_type_double;
    STRUCT(CGRect, CGFloatFFI, CGFloatFFI, CGFloatFFI, CGFloatFFI);
    STRUCT(CGPoint, CGFloatFFI, CGFloatFFI);
    STRUCT(CGSize, CGFloatFFI, CGFloatFFI);
    
#if !TARGET_OS_IPHONE
    STRUCT(NSRect, CGFloatFFI, CGFloatFFI, CGFloatFFI, CGFloatFFI);
    STRUCT(NSPoint, CGFloatFFI, CGFloatFFI);
    STRUCT(NSSize, CGFloatFFI, CGFloatFFI);
#endif
    
    NSLog(@"Unknown encode string %s", str);
    abort();
}

static ffi_type **
argsWithEncodeString(const char *str, int *outCount)
{
    int argsCount = getArgumentCount(str);
    ffi_type **argTypes = allocate(argsCount * sizeof(*argTypes));
    
    //第一个是返回值
    int i = -1;
    while (str && *str) {
        if (i > -1) {
            argTypes[i] = ffiArgumentForEncode(str);
        }
        str = NSGetSizeAndAlignment(str, NULL, NULL);
        while (isdigit(*str)) {
            str++;
        }
        i++;
    }
    *outCount =  argsCount;
    return argTypes;
}

ffi_cif g_cif;
ffi_closure *g_closure;
void *g_fptr;
id g_block;


// MARK:- 第二题


//1. 准备好参数数据及其对应ffi_type数组、返回值内存指针、函数指针
//2. 创建与函数特征相匹配的函数原型：ffi_cif对象
//3. 使用“ffi_call”来完成函数调用

//ffi_cfi
//返回值
//实参
//函数指针
void block_ffi_function(ffi_cif *cif, void *ret, void **args, void *userdata) {
    
    int a = *((int *)args[1]);
    NSString *b = (__bridge NSString *)(*((void **)args[2]));
    NSLog(@"%d, %@", a, b);
    //动态调用指定函数(原来的函数)
    ffi_call(cif, (void (*)(void))userdata, ret, args);
}

void HookBlockToPrintArguments(id block){
    
    //记录原来的block
    g_block = block;
    
    //桥接为结构体
    struct N_Block_layout *imp = (__bridge struct N_Block_layout *)block;
    
    //获取方法签名
    const char *signature = getSignature(block);
    //获取函数h指针
    g_fptr = imp->invoke;
    NSLog(@"函数签名:%s",signature);
    
    
    //编码参数类型,参数个数
    int argCount = 0;
    ffi_type **types = argsWithEncodeString(signature, &argCount);
    
    //生成函数模板
    ffi_prep_cif(&g_cif, FFI_DEFAULT_ABI, argCount, ffiArgumentForEncode(signature), types);
    //初始化ffi_closure
    g_closure = mmap(NULL, sizeof(ffi_closure), PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    
    ffi_status  status = ffi_prep_closure(g_closure, &g_cif, block_ffi_function,g_fptr);
    if (status != FFI_OK) {
        NSLog(@"ffi_prep_closure returned %d", (int)status);
        abort();
    }
    if(mprotect(g_closure, sizeof(g_closure), PROT_READ | PROT_EXEC) == -1) {
        perror("mprotect");
        abort();
    }
    //交换 函数原型
    imp->invoke = (void *)g_closure;
}


// MARK:- 第三题

//保存原来的函数指针
static id (*orig_objc_retainBlock)(id);

//函数原型
id hook_objc_retainBlock(id block) {
    id ret = orig_objc_retainBlock(block);
    HookBlockToPrintArguments(ret);
    return ret;
}

void HookEveryBlockToPrintArguments() {

    rebind_symbols(
                   (struct rebinding[1]){
                       {"objc_retainBlock",
                           hook_objc_retainBlock,
                           (void *)&orig_objc_retainBlock
                       }
                   }, 1);
}



int main(int argc, const char * argv[]) {
    @autoreleasepool {
        

        NSLog(@"______Question:One_______");
        //1:
        void (^block)(void) = ^{
            NSLog(@"____");
        };
        
        HookBlockToPrintHelloWorld(block);
        block();
        
        
        NSLog(@"______Question:Two_______");
        //2:
        void (^block2)(int a,NSString *str) = ^(int a,NSString* str){
            
            NSLog(@"Block2");
        };
        
        HookBlockToPrintArguments(block2);
        block2(5,@"Hello");
        
        NSLog(@"______Question:Three_______");
        //3:
        HookEveryBlockToPrintArguments();
        void(^blockTest3)(int, NSString *) = ^(int a, NSString *b) {
            NSLog(@"block3 invoke");
        };
        blockTest3(456, @"bbb");
        
    }
    return 0;
}
