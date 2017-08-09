//
//  AvatarView.h
//  JianShuMianPage
//
//  Created by 王振标 on 2017/8/9.
//  Copyright © 2017年 王振标. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvatarView : UIView

/**
 放置头像的ImageView
 */
@property (nonatomic, strong) UIImageView *avatar;

/**
 设置头像缩放

 @param scale 缩放比例
 */
- (void)setupScale:(CGFloat)scale;

@end
