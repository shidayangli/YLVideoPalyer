//
//  ViewController.m
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/23.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import "ViewController.h"
#import "YLPlayerView.h"
#import <AVFoundation/AVFoundation.h>

static const NSString *PlayerItemStatusContext;

@interface ViewController ()

@property (nonatomic, strong) YLPlayerView *playerView;
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic, assign) NSInteger totalSeconds;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpPlayerView];
    [self setUpKVO];
    [self setUpUI];
}

- (void)dealloc {
    [self.playerView.queuePlayer removeObserver:self forKeyPath:@"status"];
    [self.playerView.queuePlayer removeObserver:self forKeyPath:@"rate"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private methods
- (void)setUpPlayerView {
    NSArray *urlStringArray = @[@"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/6/136/C5guMiVTT5e28yYPfFIkAC.mp4", @"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/125/118/fSqpBLwVRWir1S4jkO0EWA.mp4", @"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/237/217/DSRTgyVhRBGaanAlDzsAjC.mp4", @"https://data.vod.itc.cn/?prod=rtb&new=/219/169/7pDl8WzpIH8o9J5T1jqGvC.mp4", @"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/71/198/ScvYTiKRSIqfZUzXnK99bE.mp4"];
    
    __weak typeof(self) weakSelf = self;
    TimePeriodBlock block = ^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSInteger currentSeconds = CMTimeGetSeconds(time);
        NSString *countDownLabelText = [NSString stringWithFormat:@"%ld", (self.totalSeconds - currentSeconds)];
        strongSelf.countDownLabel.text = countDownLabelText;
    };
    
    CGRect playerViewRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9 / 16);
    self.playerView = [[YLPlayerView alloc] initWithFrame:playerViewRect
                                      videoURLStringArray:urlStringArray
                                          timePeriodBlock:block];
    [self.view addSubview:self.playerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)setUpKVO {
    [self.playerView.queuePlayer addObserver:self
                                  forKeyPath:@"status"
                                     options:NSKeyValueObservingOptionNew
                                     context:&PlayerItemStatusContext];
    
    [self.playerView.queuePlayer addObserver:self
                                  forKeyPath:@"rate"
                                     options:NSKeyValueObservingOptionNew
                                     context:&PlayerItemStatusContext];
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

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != &PlayerItemStatusContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        if (self.playerView.queuePlayer) {
            if (self.playerView.queuePlayer.status == AVPlayerStatusReadyToPlay) {
                self.totalSeconds = [self.playerView getTotalSeconds];
                self.countDownLabel.text = [NSString stringWithFormat:@"%ld", (long)self.totalSeconds];
                [self.playerView.queuePlayer play];
            }
        }
    }
    
    if ([keyPath isEqualToString:@"rate"]) {
        NSNumber *rateNumber = (NSNumber *)change[NSKeyValueChangeNewKey];
        if (rateNumber) {
            NSLog(@"-----------------%@", rateNumber);
        }
    }
}

#pragma mark - Notification
- (void)moviePlayDidEnd:(NSNotification *)notification {
    if (self.playerView.queuePlayer.items && self.playerView.queuePlayer.items.count > 0) {
        self.totalSeconds -= (NSInteger)CMTimeGetSeconds(self.playerView.queuePlayer.items.firstObject.asset.duration);
    }
}

@end
