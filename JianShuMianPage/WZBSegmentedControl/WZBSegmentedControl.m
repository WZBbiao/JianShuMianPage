//
//  WZBSegmentedControl.m
//  WZBSegmentedControl
//
//  Created by normal on 2016/11/8.
//  Copyright © 2016年 WZB. All rights reserved.
//

#import "WZBSegmentedControl.h"

#define WZBButtonTag 9999
// view圆角
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// rgb
#define WZBColor(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1.0]

// 根据颜色拿到RGB数值
void getRGBValue(CGFloat colorArr[3], UIColor *color) {
    unsigned char data[4];
    // 宽,高,内存中像素的每个组件的位数（RGB应该为32）,bitmap的每一行在内存所占的比特数
    size_t width = 1, height = 1, bitsPerComponent = 8, bytesPerRow = 4;
    // bitmap上下文使用的颜色空间
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    // 指定bitmap是否包含alpha通道
    uint32_t bitmapInfo = 1;
    // 创建一个位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项。alpha值决定了绘制像素的透明性
    CGContextRef context = CGBitmapContextCreate(&data, width, height, bitsPerComponent, bytesPerRow, space, bitmapInfo);
    // 设置当前上下文中填充颜色
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 在此区域内填入当前填充颜色
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(space);
    for (NSInteger i = 0; i < 3; i++) {
        colorArr[i] = data[i];
    }
}

@interface WZBSegmentedControl ()
// 所有button
@property (nonatomic, strong) NSMutableArray *allButtons;
// 上一次选中的下标
@property (nonatomic, assign) NSInteger lastIndex;

@end

@implementation WZBSegmentedControl

#pragma mark - lazy -- 默认颜色
- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = [UIColor blackColor];
    }
    return _normalColor;
}
- (UIColor *)selectColor {
    if (!_selectColor) {
        _selectColor = [UIColor redColor];
    }
    return _selectColor;
}
- (UIColor *)sliderColor {
    if (!_sliderColor) {
        _sliderColor = [UIColor whiteColor];
    }
    return _sliderColor;
}
- (UIColor *)edgingColor {
    if (!_edgingColor) {
        _edgingColor = [UIColor whiteColor];
    }
    return _edgingColor;
}

- (NSMutableArray *)allButtons {
    if (!_allButtons) {
        _allButtons = [NSMutableArray array];
    }
    return _allButtons;
}

+ (instancetype)segmentWithFrame:(CGRect)frame titles:(NSArray *)titles tClick:(void(^)(NSInteger index))tClick {
    return [[self alloc] initWithFrame:frame titles:titles tClick:tClick];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles tClick:(void(^)(NSInteger index))tClick {
    if (self = [super initWithFrame:frame]) {
        _titles = titles;
        self.tClick = tClick;
        // 设置其他基本属性
        [self setupBase];
    }
    return self;
}

/* 初始化方法，block回调中带有选中的button */
+ (instancetype)segmentWithFrame:(CGRect)frame titles:(NSArray *)titles titleClick:(void(^)(NSInteger index, UIButton *selectButton))titleClick {
    return [[self alloc] initWithFrame:frame titles:titles titleClick:titleClick];
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles titleClick:(void(^)(NSInteger index, UIButton *selectButton))titleClick {
    if (self = [super initWithFrame:frame]) {
        _titles = titles;
        self.titleClick = titleClick;
        // 设置其他基本属性
        [self setupBase];
    }
    return self;
}

- (void)setupBackgroundView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:(CGRect){0, 0, self.frame.size.width / self.titles.count, self.frame.size.height}];
    [self addSubview:backgroundView];
    backgroundView.backgroundColor = self.edgingColor;
    _backgroundView = backgroundView;
}

- (void)setupAllButton {
    NSInteger count = self.titles.count;
    for (NSInteger i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:button];
        CGFloat x = i * self.frame.size.width / count;
        CGFloat y = 0;
        CGFloat w = self.frame.size.width / count;
        CGFloat h = self.frame.size.height;
        button.frame = CGRectMake(x, y, w, h);
        [button setTitle:self.titles[i] forState:UIControlStateNormal];
        [button setTitleColor:self.normalColor forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        button.backgroundColor = [UIColor clearColor];
        button.tag = WZBButtonTag + i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setAdjustsImageWhenHighlighted:NO];
        // 添加到数组中
        [self.allButtons addObject:button];
    }
}

- (void)setupBase {
    // 默认有1的边框
    self.edgingWidth = 1.0f;
    // 创建底部白色滑块
    [self setupBackgroundView];
    // 创建所有按钮
    [self setupAllButton];
    // 先调一下这个方法，默认选择第一个按钮
    [self buttonClick:[self viewWithTag:WZBButtonTag]];
    // 监听这两个属性，因为它们有可能在外界被用户更改，而内部不知道，就会导致bug
    [self.layer addObserver:self forKeyPath:@"borderWidth" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.layer addObserver:self forKeyPath:@"borderColor" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    // 设置圆角
    ViewBorderRadius(self, self.frame.size.height / 2, self.edgingWidth, self.edgingColor);
    ViewBorderRadius(self.backgroundView, self.frame.size.height / 2, 0, [UIColor clearColor]);
}

- (void)buttonClick:(UIButton *)button {
    [self.selectButton setTitleColor:self.normalColor forState:UIControlStateNormal];
    [button setTitleColor:self.selectColor forState:UIControlStateNormal];
    _selectButton = button;
    
    // [self setContentOffset:(CGPoint){(button.tag - WZBButtonTag) * (self.frame.size.width) / self.titles.count, 0}];
    
    NSInteger selectIndex = button.tag - WZBButtonTag;
    // 调用代理和block
    if (self.titleClick) {
        self.titleClick(selectIndex, self.selectButton);
    }
    if (self.tClick) {
        self.tClick(selectIndex);
    }
    if ([self.delegate respondsToSelector:@selector(segmentedValueDidChange:selectIndex:)]) {
        [self.delegate segmentedValueDidChange:self selectIndex:selectIndex];
    }
    if ([self.delegate respondsToSelector:@selector(segmentedValueDidChange:selectIndex:fromeIndex:)]) {
        [self.delegate segmentedValueDidChange:self selectIndex:selectIndex fromeIndex:self.lastIndex];
    }
    if ([self.delegate respondsToSelector:@selector(segmentedValueDidChange:selectIndex:fromeIndex:selectButton:)]) {
        [self.delegate segmentedValueDidChange:self selectIndex:selectIndex fromeIndex:self.lastIndex selectButton:button];
    }
    if ([self.delegate respondsToSelector:@selector(segmentedValueDidChange:selectIndex:fromeIndex:selectButton:allButtons:)]) {
        [self.delegate segmentedValueDidChange:self selectIndex:selectIndex fromeIndex:self.lastIndex selectButton:button allButtons:self.allButtons];
    }
    // 给最后一个下标赋值
    self.lastIndex = selectIndex;
}

- (void)setNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor {
    self.normalColor = normalColor;
    self.selectColor = selectColor;
    [self setAllColors];
}

- (void)setAllColors {
    // 设置所有button的颜色
    for (NSInteger i = 0; i < self.titles.count; i++) {
        UIButton *button = [self viewWithTag:i + WZBButtonTag];
        [button setTitleColor:self.normalColor forState:UIControlStateNormal];
    }
    [self.selectButton setTitleColor:self.selectColor forState:UIControlStateNormal];
    // 设置滑块的颜色
    self.backgroundView.backgroundColor = self.sliderColor;
    // 设置边框颜色
    self.layer.borderColor = self.edgingColor.CGColor;
    self.layer.borderWidth = self.edgingWidth;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    // 改变底部滑块的x值
    CGRect frame = self.backgroundView.frame;
    frame.origin.x = contentOffset.x;
    self.backgroundView.frame = frame;
    
    // 找出要操作的两个button设置颜色
    NSMutableArray *buttonArr = [NSMutableArray array];
    for (UIButton *button in self.allButtons) {
        CGFloat overLapWidth = CGRectIntersection(button.frame, self.backgroundView.frame).size.width;
        if (overLapWidth > 0) {
            [buttonArr addObject:button];
        }
    }
    
    // 切换的时候
    if (buttonArr.count > 1) {
        UIButton *leftButton = buttonArr.firstObject;
        UIButton *rightButton = buttonArr.lastObject;
        // 设置要渐变的两个button颜色
        [rightButton setTitleColor:WZBColor([self getRGBValueWithIndex:0 button:rightButton], [self getRGBValueWithIndex:1 button:rightButton], [self getRGBValueWithIndex:2 button:rightButton]) forState:UIControlStateNormal];
        [leftButton setTitleColor:WZBColor([self getRGBValueWithIndex:0 button:leftButton], [self getRGBValueWithIndex:1 button:leftButton], [self getRGBValueWithIndex:2 button:leftButton]) forState:UIControlStateNormal];
    }
    
    // 重新设置选中的button
    _selectButton = [self viewWithTag:(NSInteger)(WZBButtonTag + self.backgroundView.center.x / (self.frame.size.width / self.titles.count))];
}

// 根据button拿到当前button的RGB数值 index:0为R，1为G，2为B，button:是当前button
- (CGFloat)getRGBValueWithIndex:(NSInteger)index button:(UIButton *)button {
    // 创建两个数组接收颜色的RGB
    CGFloat leftRGB[3];
    CGFloat rightRGB[3];
    getRGBValue(leftRGB, self.normalColor);
    getRGBValue(rightRGB, self.selectColor);
    // 计算当前button和滑块的交叉区域宽度
    CGFloat overLapWidth = CGRectIntersection(button.frame, self.backgroundView.frame).size.width;
    CGFloat value = overLapWidth / button.frame.size.width;
    // 返回RGB值
    if ([button isEqual:self.selectButton]) {
        return leftRGB[index] + value * (rightRGB[index] - leftRGB[index]);
    } else {
        return rightRGB[index] + (1 - value) * (leftRGB[index] - rightRGB[index]);
    }
}

// 设置部分颜色
- (void)setNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor edgingColor:(UIColor *)edgingColor {
    self.normalColor = normalColor;
    self.selectColor = selectColor;
    self.edgingColor = edgingColor;
    [self setAllColors];
}

// 设置所有颜色
- (void)setNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor sliderColor:(UIColor *)sliderColor edgingColor:(UIColor *)edgingColor {
    self.normalColor = normalColor;
    self.selectColor = selectColor;
    self.sliderColor = sliderColor;
    self.edgingColor = edgingColor;
    [self setAllColors];
}

// 设置所有属性
- (void)setNormalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor sliderColor:(UIColor *)sliderColor edgingColor:(UIColor *)edgingColor edgingWidth:(CGFloat)edgingWidth {
    self.normalColor = normalColor;
    self.selectColor = selectColor;
    self.sliderColor = sliderColor;
    self.edgingColor = edgingColor;
    self.edgingWidth = edgingWidth;
    [self setAllColors];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"borderWidth"] || [keyPath isEqualToString:@"borderColor"]) {
        self.edgingColor = [UIColor colorWithCGColor:self.layer.borderColor];
        self.edgingWidth = self.layer.borderWidth;
    }
}
// 移除观察者
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"borderWidth"];
    [self removeObserver:self forKeyPath:@"borderColor"];
}

@end
