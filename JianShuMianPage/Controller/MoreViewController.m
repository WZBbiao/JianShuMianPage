//
//  MoreViewController.m
//  JianShuMianPage
//
//  Created by 王振标 on 2017/8/9.
//  Copyright © 2017年 王振标. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (NSArray *)dataSource
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < 30; i++) {
        [array addObject:@"更多tableView"];
    }
    return array;
}

@end
