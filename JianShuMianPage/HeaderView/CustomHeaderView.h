//
//  CustomHeaderView.h
//  JianShuMianPage
//
//  Created by 王振标 on 2017/8/9.
//  Copyright © 2017年 王振标. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZBSegmentedControl, HeaderView;

@interface CustomHeaderView : UIView

/**
 点击segment的时候调用
 */
@property (nonatomic, copy) void(^segmentSelected)(NSInteger index);

/**
 可滑动的segmentedControl
 */
@property (nonatomic, strong) WZBSegmentedControl *sectionView;

/**
 修改frame值
 */
- (void)changeY:(CGFloat)y;
- (void)changeX:(CGFloat)x;

@end
