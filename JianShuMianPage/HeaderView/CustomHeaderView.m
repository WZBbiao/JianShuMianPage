//
//  CustomHeaderView.m
//  JianShuMianPage
//
//  Created by 王振标 on 2017/8/9.
//  Copyright © 2017年 王振标. All rights reserved.
//

#import "CustomHeaderView.h"
#import "WZBSegmentedControl.h"
#import "HeaderView.h"
#import "Const.h"

@implementation CustomHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
        
        // 创建headerView
        HeaderView *header = [HeaderView headerView:(CGRect){0, 0, WZBScreenWidth, 150}];
        // 创建segmentedControl
        WZBSegmentedControl *sectionView = [WZBSegmentedControl segmentWithFrame:(CGRect){0, 150, WZBScreenWidth, 44} titles:@[@"动态", @"文章", @"更多"] tClick:^(NSInteger index) {
            if (self.segmentSelected) self.segmentSelected(index);
        }];
        
        // 赋值给全局变量
        self.sectionView = sectionView;
        
        // 设置其他颜色
        [sectionView setNormalColor:[UIColor blackColor] selectColor:[UIColor redColor] sliderColor:[UIColor redColor] edgingColor:[UIColor clearColor] edgingWidth:0];
        
        // 去除圆角
        sectionView.layer.cornerRadius = sectionView.backgroundView.layer.cornerRadius = .0f;
        
        // 加两条线
        for (NSInteger i = 0; i < 2; i++) {
            UIView *line = [UIView new];
            line.backgroundColor = WZBColor(228, 227, 230);
            line.frame = CGRectMake(0, 43.5 * i, WZBScreenWidth, 0.5);
            [sectionView addSubview:line];
        }
        // 调下frame
        CGRect frame = sectionView.backgroundView.frame;
        frame.origin.y = frame.size.height - 1.5;
        frame.size.height = 1;
        sectionView.backgroundView.frame = frame;
        [self addSubview:header];
        [self addSubview:sectionView];
    }
    return self;
}

- (void)changeY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

// 禁掉手势
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:UIButton.class]) return view;
    return nil;
}

@end
