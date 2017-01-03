//
//  ViewController.m
//  JianShuMianPage
//
//  Created by 王振标 on 2016/12/26.
//  Copyright © 2016年 王振标. All rights reserved.
//

#import "ViewController.h"
#import "HeaderView.h"
#import "WZBSegmentedControl.h"

#define WZBScreenWidth [UIScreen mainScreen].bounds.size.width
#define WZBScreenHeight [UIScreen mainScreen].bounds.size.height
// san最大的
#define MAXValue(a,b,c) (a>b?(a>c?a:c):(b>c?b:c))
// rgb
#define WZBColor(r, g, b) [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:1.0]

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

// 左边的tableView
@property (nonatomic, strong) UITableView *leftTableView;

// 中间的tableView
@property (nonatomic, strong) UITableView *centerTableView;

// 右边的tableView
@property (nonatomic, strong) UITableView *rightTableView;

// 顶部的headeView
@property (nonatomic, strong) UIView *headerView;

// 可滑动的segmentedControl
@property (nonatomic, strong) WZBSegmentedControl *sectionView;

// 底部横向滑动的scrollView，上边放着三个tableView
@property (nonatomic, strong) UIScrollView *scrollView;

// 头部头像
@property (nonatomic, strong) UIImageView *avatar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 底部横向滑动的scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
    
    // 绑定代理
    scrollView.delegate = self;
    
    // 设置滑动区域
    scrollView.contentSize = CGSizeMake(3 * WZBScreenWidth, 0);
    scrollView.pagingEnabled = YES;
    self.scrollView = scrollView;
    
    // 创建headerView
    HeaderView *header = [HeaderView headerView:(CGRect){0, 0, WZBScreenWidth, 150}];
    
    // 创建segmentedControl
    WZBSegmentedControl *sectionView = [WZBSegmentedControl segmentWithFrame:(CGRect){0, 150, WZBScreenWidth, 44} titles:@[@"动态", @"文章", @"更多"] tClick:^(NSInteger index) {
        
        // 改变scrollView的contentOffset
        self.scrollView.contentOffset = CGPointMake(index * WZBScreenWidth, 0);
        
        
        // 刷新最大OffsetY
        [self reloadMaxOffsetY];
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
    
    // headerView
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, WZBScreenWidth, CGRectGetMaxY(sectionView.frame)}];
    headerView.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
    [headerView addSubview:header];
    [headerView addSubview:sectionView];
    self.headerView = headerView;
    
    [self.view addSubview:headerView];
    
    // 创建三个tableView
    self.leftTableView = [self tableViewWithX:0];
    self.centerTableView = [self tableViewWithX:WZBScreenWidth];
    self.rightTableView = [self tableViewWithX:WZBScreenWidth * 2];
    
    // 加载头部头像
    UIView *avatarView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 35, 35}];
    avatarView.backgroundColor = [UIColor clearColor];
    
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:(CGRect){0, 26.5, 35, 35}];
    avatar.image = [UIImage imageNamed:@"demo1"];
    avatar.layer.masksToBounds = YES;
    avatar.layer.cornerRadius = 35 / 2;
    [avatarView addSubview:avatar];
    self.navigationItem.titleView = avatarView;
    avatar.transform = CGAffineTransformMakeScale(2, 2);
    
    self.avatar = avatar;
}

// 创建tableView
- (UITableView *)tableViewWithX:(CGFloat)x {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(x, 0, WZBScreenWidth, WZBScreenHeight - 0)];
    [self.scrollView addSubview:tableView];
    tableView.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
    tableView.showsVerticalScrollIndicator = NO;
    
    // 代理&&数据源
    tableView.delegate = self;
    tableView.dataSource = self;
    
    // 创建一个假的headerView，高度等于headerView的高度
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, WZBScreenWidth, 194}];

    tableView.tableHeaderView = headerView;
    return tableView;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
    if (tableView == self.leftTableView) {
        cell.textLabel.text = @"左边tableView";
    }
    if (tableView == self.centerTableView) {
        cell.textLabel.text = @"中间tableView";
    }
    if (tableView == self.rightTableView) {
        cell.textLabel.text = @"右边tableView";
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 如果当前滑动的是tableView
    if ([scrollView isKindOfClass:[UITableView class]]) {
        
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        
        // 如果滑动没有超过150
        if (contentOffsetY < 150) {
            
            // 让这三个tableView的偏移量相等
            self.leftTableView.contentOffset = self.centerTableView.contentOffset = self.rightTableView.contentOffset = scrollView.contentOffset;
            
            // 改变headerView的y值
            CGRect frame = self.headerView.frame;
            CGFloat y = -self.rightTableView.contentOffset.y;
            frame.origin.y = y;
            self.headerView.frame = frame;
            
            // 一旦大于等于150了，让headerView的y值等于150，就停留在上边了
        } else if (contentOffsetY >= 150) {
            CGRect frame = self.headerView.frame;
            frame.origin.y = -150;
            self.headerView.frame = frame;
        }
    }
    
    if (scrollView == self.scrollView) {
        // 改变segmentdControl
        [self.sectionView setContentOffset:(CGPoint){scrollView.contentOffset.x / 3, 0}];
        return;
    }
    
    
    // 处理顶部头像
    CGFloat scale = scrollView.contentOffset.y / 80;
    
    // 如果大于80，==1，小于0，==0
    if (scrollView.contentOffset.y > 80) {
        scale = 1;
    } else if (scrollView.contentOffset.y <= 0) {
        scale = 0;
    }
    
    // 缩放
    self.avatar.transform = CGAffineTransformMakeScale(2 - scale, 2 - scale);
    
    // 同步y值
    CGRect frame = self.avatar.frame;
    frame.origin.y = (1 - scale) * 8;
    self.avatar.frame = frame;
}

// 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        
        // 刷新最大OffsetY
        [self reloadMaxOffsetY];
    }
}

// 刷新最大OffsetY，让三个tableView同步
- (void)reloadMaxOffsetY {
    
    // 计算出最大偏移量
    CGFloat maxOffsetY = MAXValue(self.leftTableView.contentOffset.y, self.centerTableView.contentOffset.y, self.rightTableView.contentOffset.y);
    
    // 如果最大偏移量大于150，处理下每个tableView的偏移量
    if (maxOffsetY > 150) {
        if (self.leftTableView.contentOffset.y < 150) {
            self.leftTableView.contentOffset = CGPointMake(0, 150);
        }
        if (self.centerTableView.contentOffset.y < 150) {
            self.centerTableView.contentOffset = CGPointMake(0, 150);
        }
        if (self.rightTableView.contentOffset.y < 150) {
            self.rightTableView.contentOffset = CGPointMake(0, 150);
        }
    }
}
@end
