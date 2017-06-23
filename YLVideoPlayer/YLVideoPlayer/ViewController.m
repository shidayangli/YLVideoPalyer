//
//  ViewController.m
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/23.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

static const NSString *PlayerItemStatusContext;

@interface ViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic, assign) NSInteger totalSeconds;
@property (nonatomic, strong) id timeObserver;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpAVPlayer];
    [self setUpUI];
    [self addPlayerItemTimeObserver];
}

- (void)dealloc {
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    if (self.timeObserver) {
        [self.player removeTimeObserver:self];
        self.timeObserver = nil;
    }
}

#pragma mark - private methods
- (void)setUpAVPlayer {
    NSString *urlString = @"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/71/198/ScvYTiKRSIqfZUzXnK99bE.mp4";
    NSURL *url = [NSURL URLWithString:urlString];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9 / 16);
    [self.view.layer addSublayer:playerLayer];
    
    [self.currentItem addObserver:self
                       forKeyPath:@"status"
                          options:0
                          context:&PlayerItemStatusContext];
}

- (void)addPlayerItemTimeObserver {
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player
                         addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                         queue:dispatch_get_main_queue()
                         usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSInteger currentSeconds = CMTimeGetSeconds(time);
        NSString *countDownLabelText = [NSString stringWithFormat:@"%ld", (self.totalSeconds - currentSeconds)];
        strongSelf.countDownLabel.text = countDownLabelText;
    }];
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
                    [self.player play];
                }
            }
        }
    }
}

@end
