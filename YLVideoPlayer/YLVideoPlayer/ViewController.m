//
//  ViewController.m
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/23.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentItem;

@end

@implementation ViewController

static const NSString *PlayerItemStatusContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://data.vod.itc.cn/?pt=3&pg=1&prod=ad&new=/71/198/ScvYTiKRSIqfZUzXnK99bE.mp4"];
    AVAsset *asset = [AVAsset assetWithURL:url];
    self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 9 / 16);
    [self.view.layer addSublayer:playerLayer];
    [self.currentItem addObserver:self forKeyPath:@"status" options:0 context:&PlayerItemStatusContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == &PlayerItemStatusContext) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerItem *currentPlayerItem = (AVPlayerItem *)object;
            if (currentPlayerItem) {
                if (currentPlayerItem.status == AVPlayerItemStatusReadyToPlay) {
                    [self.player play];
                }
            }
        }
    }
}

- (void)dealloc {
    [self.currentItem removeObserver:self forKeyPath:@"status"];
}


@end
