//
//  ArticleViewController.m
//  JianShuMianPage
//
//  Created by 王振标 on 2017/8/9.
//  Copyright © 2017年 王振标. All rights reserved.
//

#import "ArticleViewController.h"

@interface ArticleViewController ()

@end

@implementation ArticleViewController

- (NSArray *)dataSource
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < 30; i++) {
        [array addObject:@"文章tableView"];
    }
    return array;
}

@end
