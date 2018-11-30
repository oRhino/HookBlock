//
//  MergeSortedList.h
//  Arithmetic
//
//  Created by Rhino on 2018/11/29.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MergeSortedList : NSObject

// 将有序数组a和b的值合并到一个数组result当中，且仍然保持有序
void mergeList(int a[], int aLen, int b[], int bLen, int result[]);

@end

NS_ASSUME_NONNULL_END
