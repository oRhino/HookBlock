//
//  ViewController.m
//  AppHook
//
//  Created by Rhino on 2018/11/28.
//  Copyright © 2018 Rhino. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonClick:(id)sender{
    NSLog(@"购买:%s",__func__);
}


@end
