//
//  DynamicViewController.m
//  JianShuMianPage
//
//  Created by 王振标 on 2017/8/9.
//  Copyright © 2017年 王振标. All rights reserved.
//

#import "DynamicViewController.h"

@interface DynamicViewController ()

@end

@implementation DynamicViewController

- (NSArray *)dataSource
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < 30; i++) {
        [array addObject:@"动态tableView"];
    }
    return array;
}

@end
