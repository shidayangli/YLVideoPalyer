//
//  ViewController.m
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/23.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import "ViewController.h"
#import "YLPlayerMutiplePresenter.h"
#import "YLPlayerSinglePresenter.h"

@interface ViewController ()<YLPlayerMutiplePresenterDelegate, YLPlayerSinglePresenterDelegate>

@property (nonatomic, readwrite, strong) UILabel *countDownLabel;
@property (nonatomic, readwrite, assign) NSInteger totalSeconds;
@property (nonatomic, readwrite, strong) YLPlayerMutiplePresenter *mutiplePresenter;
@property (nonatomic, readwrite, strong) YLPlayerSinglePresenter *singlePresenter;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpPlayerSinglePresenter];
    [self setUpUI];
}

#pragma mark - private methods
- (void)setUpPlayerSinglePresenter {
    NSString *urlString = @"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";
    
    __weak typeof(self) weakSelf = self;
    TimePeriodBlock block = ^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSInteger currentSeconds = CMTimeGetSeconds(time);
        NSString *countDownLabelText = [NSString stringWithFormat:@"%ld", (strongSelf.totalSeconds - currentSeconds)];
        strongSelf.countDownLabel.text = countDownLabelText;
    };
    
    CGRect playerViewRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9 / 16);
    self.singlePresenter = [[YLPlayerSinglePresenter alloc] initWithFrame:playerViewRect
                                                           videoURLString:urlString
                                                          timePeriodBlock:block
                                                            containerView:self.view
                                                                 delegate:self];
}

- (void)setUpPlayerMutiplePresenter {
    NSArray *urlStringArray = @[@"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/6/136/C5guMiVTT5e28yYPfFIkAC.mp4",
                                @"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/125/118/fSqpBLwVRWir1S4jkO0EWA.mp4",
                                @"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/237/217/DSRTgyVhRBGaanAlDzsAjC.mp4",
                                @"https://data.vod.itc.cn/?prod=rtb&new=/219/169/7pDl8WzpIH8o9J5T1jqGvC.mp4",
                                @"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/71/198/ScvYTiKRSIqfZUzXnK99bE.mp4"];
    
    __weak typeof(self) weakSelf = self;
    TimePeriodBlock block = ^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSInteger currentSeconds = CMTimeGetSeconds(time);
        NSString *countDownLabelText = [NSString stringWithFormat:@"%ld", (strongSelf.totalSeconds - currentSeconds)];
        strongSelf.countDownLabel.text = countDownLabelText;
    };
    
    CGRect playerViewRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9 / 16);
    self.mutiplePresenter = [[YLPlayerMutiplePresenter alloc] initWithFrame:playerViewRect
                                                        videoURLStringArray:urlStringArray
                                                            timePeriodBlock:block
                                                              containerView:self.view
                                                                   delegate:self];
}

- (void)setUpUI {
    self.countDownLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor redColor];
        [self.view addSubview:label];
        label;
    });
}

#pragma mark - YLPlayerMutiplePresenterDelegate
- (void)playerDidEndOneVideo:(YLPlayerMutiplePresenter *)presenter currentDuration:(NSInteger)duration {
    self.totalSeconds -= duration;
}

- (void)playerWillPlay:(YLPlayerMutiplePresenter *)presenter totalDuration:(NSInteger)duration {
    self.totalSeconds = duration;
}

#pragma mark - YLPlayerSinglePresenterDelegate
- (void)playerWillPlay:(YLPlayerSinglePresenter *)presenter duration:(NSInteger)duration {
    self.totalSeconds = duration;
}

@end
