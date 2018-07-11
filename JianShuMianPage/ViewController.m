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
#import "MoreViewController.h"
#import "ArticleViewController.h"
#import "DynamicViewController.h"
#import "CustomHeaderView.h"
#import "Const.h"
#import "AvatarView.h"
#import "MJRefresh.h"

@interface ViewController () <UIScrollViewDelegate>
// 顶部的headeView
@property (nonatomic, strong) CustomHeaderView *headerView;

// 底部横向滑动的scrollView，上边放着三个tableView
@property (nonatomic, strong) WZBScrollView *scrollView;

// 头部头像
@property (nonatomic, strong) AvatarView *avatarView;
@property (nonatomic, strong) UISwitch *refreshSwitch;
// 记录当前选中的控制器
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 底部横向滑动的scrollView
    WZBScrollView *scrollView = [[WZBScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
    // 绑定代理
    scrollView.delegate = self;
    // 设置滑动区域
    scrollView.contentSize = CGSizeMake(3 * WZBScreenWidth, 0);
    scrollView.pagingEnabled = YES;
    self.scrollView = scrollView;
    
    // 创建控制器
    CGFloat width = self.view.frame.size.width;
    [self setupChildVc:DynamicViewController.class x:0];
    [self setupChildVc:ArticleViewController.class x:width];
    [self setupChildVc:MoreViewController.class x:width * 2];
    
    // headerView
    CustomHeaderView *headerView = [[CustomHeaderView alloc] initWithFrame:(CGRect){0, 0, WZBScreenWidth, 194}];
    headerView.segmentSelected = ^(NSInteger index) {
        // 切换的时候记录一下当前选中的控制器
        self.selectedIndex = index;
        
        // 改变scrollView的contentOffset
        self.scrollView.contentOffset = CGPointMake(index * WZBScreenWidth, 0);
        
        // 刷新最大OffsetY
        [self reloadMaxOffsetY];
    };
    self.headerView = headerView;
    [scrollView addSubview:headerView];
    
    // 加载头部头像
    AvatarView *avatarView = [[AvatarView alloc] initWithFrame:(CGRect){0, 0, 35, 35}];
    self.navigationItem.titleView = avatarView;
    self.avatarView = avatarView;
    
    // 导航栏右边刷新控件开关
    UISwitch *s = [UISwitch new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:s];
    [s addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    self.refreshSwitch = s;
}

- (void)setupChildVc:(Class)c x:(CGFloat)x
{
    BaseViewController *vc = [c new];
    [self.scrollView addSubview:vc.view];
    vc.view.frame = CGRectMake(x, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:vc];
    // 监听tableView的contentOffset变化
    [vc.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial context:nil];
    vc.tableView.tag = (int)(x / self.view.frame.size.width);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (self.selectedIndex != [object tag]) return;
    if ([keyPath isEqualToString:@"contentOffset"]) {
        UITableView *tableView = object;
        CGFloat contentOffsetY = tableView.contentOffset.y;
        
        // 如果滑动没有超过150
        if (contentOffsetY < 150) {
            // 让这三个tableView的偏移量相等
            for (BaseViewController *vc in self.childViewControllers) {
                if (vc.tableView.contentOffset.y != tableView.contentOffset.y) {
                    vc.tableView.contentOffset = tableView.contentOffset;
                }
            }
            CGFloat headerY = -tableView.contentOffset.y;
            if (self.refreshSwitch.isOn && headerY > 0) {
                headerY = 0;
            }
            // 改变headerView的y值
            [self.headerView changeY:headerY];
            
            // 一旦大于等于150了，让headerView的y值等于150，就停留在上边了
        } else if (contentOffsetY >= 150) {
            [self.headerView changeY:-150];
        }
        
        // 处理顶部头像
        CGFloat scale = tableView.contentOffset.y / 80;
        
        // 如果大于80，==1，小于0，==0
        if (tableView.contentOffset.y > 80) {
            scale = 1;
        } else if (tableView.contentOffset.y <= 0) {
            scale = 0;
        }
        [self.avatarView setupScale:scale];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        // 改变segmentdControl
        [self.headerView.sectionView setContentOffset:(CGPoint){scrollView.contentOffset.x / 3, 0}];
        [self.headerView changeX:scrollView.contentOffset.x];
    }
}

// 滚动停止的时候记录一下当前选中的控制器
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / self.view.frame.size.width;
    self.selectedIndex = index;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / self.view.frame.size.width;
    self.selectedIndex = index;
}

// 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 刷新最大OffsetY
    [self reloadMaxOffsetY];
}

// 刷新最大OffsetY，让三个tableView同步
- (void)reloadMaxOffsetY {
    
    // 计算出最大偏移量
    CGFloat maxOffsetY = 0;
    for (BaseViewController *vc in self.childViewControllers) {
        if (vc.tableView.contentOffset.y > maxOffsetY) {
            maxOffsetY = vc.tableView.contentOffset.y;
        }
    }
    
    // 如果最大偏移量大于150，处理下每个tableView的偏移量
    if (maxOffsetY > 150) {
        for (BaseViewController *vc in self.childViewControllers) {
            if (vc.tableView.contentOffset.y < 150) {
                vc.tableView.contentOffset = CGPointMake(0, 150);
            }
        }
    }
}

- (void)switchAction:(UISwitch *)s
{
    if (s.isOn) {
        // 添加刷新控件
        for (BaseViewController *vc in self.childViewControllers) {
            vc.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^(UIScrollView *scrollView){
                [scrollView.mj_header endRefreshing];
            }];
            vc.tableView.mj_header.ignoredScrollViewContentInsetTop = -194;
        }
    } else {
        // 移除刷新控件
        [[[self.childViewControllers valueForKeyPath:@"tableView"] valueForKeyPath:@"mj_header"] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [[self.childViewControllers valueForKeyPath:@"tableView"] makeObjectsPerformSelector:@selector(setMj_header:) withObject:nil];
    }
}
@end

@implementation WZBScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delaysContentTouches = NO;
    }
    
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:UIButton.class]) {
        return YES;
    }
    
    return [super touchesShouldCancelInContentView:view];
}

@end
