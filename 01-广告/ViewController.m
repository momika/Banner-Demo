//
//  ViewController.m
//  01-广告
//
//  Created by Jarvan on 16/5/13.
//  Copyright (c) 2016年 Jarvan. All rights reserved.
//

#import "ViewController.h"

/** 图片视图*/
#define VIEW_W 320
#define VIEW_H 130

@interface ViewController () <UIScrollViewDelegate>
{
    /** 图片名数组*/
    NSArray *_imageNameArr;
    
    /** 滚动视图*/
    UIScrollView *_scrollView;
    
    /** 页码控件*/
    UIPageControl *_pageControl;
    
    /** 当前页*/
    NSInteger _currentPage;
    
    /** 时钟*/
    NSTimer *_timer;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /** 
     1、显示的图片数组
     2、时钟间隔
     3、位置以及大小
     */
    
    
    // 导航栏标签栏半透明
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    
    // 0、初始化
    [self readInit];
    
    // 1、创建滚动视图
    [self createScollView];
    
    // 2、创建页码
    [self createPage];
    
    // 3、实现分页控件与视图的联动
    // 视图滚动的代理方法
    
    // 4、实现自动滚动（但分页控件不会动，就是有另外一个视图滚动的代理方法处理）
    [self createTimer];
    
    // 5、循环滚动的处理
    
    // 6、优化，实现可以来回拖动处理(就是在拖动的时候将定时器关了，拖动完成后再继续开启)
}

#pragma mark - 6、优化
// 开始
- (void)startTimer{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
    }
}

// 停止
- (void)stopTimer{
    [_timer invalidate];
    _timer = nil;
}

// 开始拖动(停止时钟)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopTimer];
}

// 结束拖动(重新开启时钟)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}


#pragma mark - 5、循环滚动的处理
- (void)changeScrollViewContentOffSet{
    if (_currentPage == 0) {    // 切换到第五张
        _currentPage = _imageNameArr.count - 2;
    }
    else if (_currentPage == _imageNameArr.count-1){    // 切换到第一张
        _currentPage = 1;
    }
    
    // 切换视图：不使用动画
    [_scrollView setContentOffset:CGPointMake(VIEW_W*_currentPage, 0) animated:NO];
    // 改变页码控件
    _pageControl.currentPage = _currentPage - 1;
}

#pragma mark -  4、实现自动滚动
- (void)createTimer{
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

- (void)update{
    // 切换图片 【当前偏移位置 + 视图宽度】
    
    // 是不会调用 "scrollViewDidEndDecelerating结束滚动" 这个代理方法的
//    _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x + VIEW_W, 0);
    
    
    // 可以使用 "scrollViewDidEndScrollingAnimation滚动动画结束" 代理方法
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + VIEW_W, 0) animated:YES];
}

#pragma mark - 3、实现分页控件与视图的联动
// 结束滚动(只有拖动操作结束后才调用)
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"结束滚动");
    
    // 当前页
    _currentPage = _scrollView.contentOffset.x / VIEW_W;
    // 修改页码控件
    _pageControl.currentPage = _currentPage - 1;
    
    
    // 第五步操作：判断是否是第零张/最后一张 【循环操作】
    [self changeScrollViewContentOffSet];
}

// 滚动动画结束
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"滚动动画结束");
    
    // 当前页
    _currentPage = _scrollView.contentOffset.x / VIEW_W;
    // 改变页码控件
    _pageControl.currentPage = _currentPage - 1;
    
    
    
    // 第五步操作：判断是否是第零张/最后一张 【循环操作】
    [self changeScrollViewContentOffSet];
}

// 页码控件的点击事件处理
- (void)pageChange:(UIPageControl *)pageControl{
    NSLog(@"%ld",pageControl.currentPage);
    
    // 改变滚动视图的偏移位置
    _scrollView.contentOffset = CGPointMake(VIEW_W*(pageControl.currentPage+1), 0);
}

#pragma mark - 2、创建页码
- (void)createPage{
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.frame = CGRectMake(0, 0, 100, 30);
    /** 
     CGRectGetMaxY(_scrollView.frame) 获取_scrollView最大的y值【视图y + 视图h】
     */
    _pageControl.center = CGPointMake(320/2, CGRectGetMaxY(_scrollView.frame)-30/2);
    _pageControl.backgroundColor = [UIColor redColor];
    _pageControl.pageIndicatorTintColor = [UIColor blackColor];
    
    // 总个数 1~5
    _pageControl.numberOfPages = _imageNameArr.count - 2;
    
    // 当前页 0~4  [实际显示：第1张到第5张]
    _pageControl.currentPage = _currentPage - 1;
    
    
    // 点击事件的添加 [触发方式UIControlEventValueChanged]
    [_pageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.view addSubview:_pageControl];
}

#pragma mark - 0、readInit
- (void)readInit{
    // 为了方便循环滚动的处理，头尾各添加一个图片
    _imageNameArr = @[@"img_05.png",    // 添加尾部图片   第零张
                      @"img_01.png",    // 第一张
                      @"img_02.png",    // 第二张
                      @"img_03.png",    // 第三张
                      @"img_04.png",    // 第四张
                      @"img_05.png",    // 第五张
                      @"img_01.png",    // 添加头部图片   第六张
                      ];
}

#pragma mark - 1、创建滚动视图
- (void)createScollView{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, 64, VIEW_W, VIEW_H);
    _scrollView.backgroundColor = [UIColor purpleColor];
    
    // 内容大小【如果滚动不了，请检查是否设置了这个属性】
    _scrollView.contentSize = CGSizeMake(VIEW_W*_imageNameArr.count, VIEW_H);
    
    // 图片拼接
    for (int i=0; i<_imageNameArr.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(VIEW_W*i, 0, VIEW_W, VIEW_H);
        imageView.image = [UIImage imageNamed:_imageNameArr[i]];
        [_scrollView addSubview:imageView];
    }
    
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    
    // 默认要显示第一张
    _currentPage = 1;
    _scrollView.contentOffset = CGPointMake(VIEW_W*_currentPage, 0);
    
    // 设置成为代理
    _scrollView.delegate = self;
    
    [self.view addSubview:_scrollView];
}

@end
