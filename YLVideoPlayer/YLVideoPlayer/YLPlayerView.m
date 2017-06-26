//
//  YLPlayerView.m
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/26.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import "YLPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface YLPlayerView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, copy) TimePeriodBlock timePeriodBlock;

@end

@implementation YLPlayerView

#pragma mark - methods override
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame videoURLString:(NSString *)urlString timePeriodBlock:(TimePeriodBlock)block {
    self = [super initWithFrame:frame];
    if (self) {
        self.timePeriodBlock = block;
        [self setUpAVPlayerWithVideoURLString:urlString];
        [self addPlayerItemTimeObserver];
    }
    return self;
}

- (void)dealloc {
    if (self.timeObserver) {
        [self.player removeTimeObserver:self];
        self.timeObserver = nil;
    }
}

#pragma mark - private methods
- (void)setUpAVPlayerWithVideoURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    [(AVPlayerLayer *)self.layer setPlayer:self.player];
}

- (void)addPlayerItemTimeObserver {
    self.timeObserver = [self.player
                         addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                         queue:dispatch_get_main_queue()
                         usingBlock:self.timePeriodBlock];
}

@end
