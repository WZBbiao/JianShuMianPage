//
//  AvatarView.m
//  JianShuMianPage
//
//  Created by 王振标 on 2017/8/9.
//  Copyright © 2017年 王振标. All rights reserved.
//

#import "AvatarView.h"

@implementation AvatarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *avatar = [[UIImageView alloc] initWithFrame:(CGRect){0, 26.5, 35, 35}];
        avatar.image = [UIImage imageNamed:@"demo1"];
        avatar.layer.masksToBounds = YES;
        avatar.layer.cornerRadius = 35 / 2;
        [self addSubview:avatar];
        avatar.transform = CGAffineTransformMakeScale(2, 2);
        self.avatar = avatar;
    }
    return self;
}

- (void)setupScale:(CGFloat)scale
{
    // 缩放
    self.avatar.transform = CGAffineTransformMakeScale(2 - scale, 2 - scale);
    
    // 同步y值
    CGRect frame = self.avatar.frame;
    frame.origin.y = (1 - scale) * 8;
    self.avatar.frame = frame;
}

@end
