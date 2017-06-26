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
    [self.playerView.currentItem removeObserver:self forKeyPath:@"status"];
}

#pragma mark - private methods
- (void)setUpPlayerView {
    NSString *urlString = @"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/71/198/ScvYTiKRSIqfZUzXnK99bE.mp4";
    
    __weak typeof(self) weakSelf = self;
    TimePeriodBlock block = ^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSInteger currentSeconds = CMTimeGetSeconds(time);
        NSString *countDownLabelText = [NSString stringWithFormat:@"%ld", (self.totalSeconds - currentSeconds)];
        strongSelf.countDownLabel.text = countDownLabelText;
    };
    
    CGRect playerViewRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9 / 16);
    self.playerView = [[YLPlayerView alloc] initWithFrame:playerViewRect
                                           videoURLString:urlString
                                          timePeriodBlock:block];
    [self.view addSubview:self.playerView];
}

- (void)setUpKVO {
    [self.playerView.currentItem addObserver:self
                                  forKeyPath:@"status"
                                     options:0
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
    if (context == &PlayerItemStatusContext) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerItem *currentPlayerItem = (AVPlayerItem *)object;
            if (currentPlayerItem) {
                if (currentPlayerItem.status == AVPlayerItemStatusReadyToPlay) {
                    self.totalSeconds = (NSInteger)CMTimeGetSeconds(currentPlayerItem.duration);
                    self.countDownLabel.text = [NSString stringWithFormat:@"%ld", (long)self.totalSeconds];
                    [self.playerView.player play];
                }
            }
        }
    }
}

@end
