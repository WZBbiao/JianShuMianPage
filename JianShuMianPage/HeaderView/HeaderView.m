//
//  HeaderView.m
//  JSMineHomePage
//
//  Created by normal on 2016/12/5.
//  Copyright © 2016年 WZB. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

+ (instancetype)headerView:(CGRect)frame {
    
    // 初始化headerView
    HeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil].firstObject;
    headerView.backgroundColor = [UIColor clearColor];
    
    // 给headerView赋值frame
    headerView.frame = frame;
    
    // 返回headerView
    return headerView;
}

@end
