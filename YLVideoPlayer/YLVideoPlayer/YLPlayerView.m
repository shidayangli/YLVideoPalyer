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
@property (nonatomic, strong) AVQueuePlayer *queuePlayer;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, copy) TimePeriodBlock timePeriodBlock;

@end

@implementation YLPlayerView

#pragma mark - public methods
- (NSInteger)getTotalSeconds {
    if (self.player && self.player.currentItem) {
        return (NSInteger)CMTimeGetSeconds(self.player.currentItem.duration);
    } else if (self.queuePlayer && self.queuePlayer.items) {
        NSInteger totalSeconds = 0;
        for (AVPlayerItem *item in self.queuePlayer.items) {
            totalSeconds += (NSInteger)CMTimeGetSeconds(item.asset.duration);
        }
        return totalSeconds;
    }
    return 0;
}

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

- (instancetype)initWithFrame:(CGRect)frame videoURLStringArray:(NSArray *)urlStringArray timePeriodBlock:(TimePeriodBlock)block {
    self = [super initWithFrame:frame];
    if (self) {
        self.timePeriodBlock = block;
        [self setUpAVPlayerWithVideoURLStringArray:urlStringArray];
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
- (void)setUpAVPlayerWithVideoURLStringArray:(NSArray *)urlStringArray {
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    for (NSString *urlString in urlStringArray) {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:urlString]];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        [itemArray addObject:item];
    }
    self.queuePlayer = [[AVQueuePlayer alloc] initWithItems:itemArray];
    [(AVPlayerLayer *)self.layer setPlayer:self.queuePlayer];
}

- (void)setUpAVPlayerWithVideoURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVPlayerItem *currentItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:currentItem];
    [(AVPlayerLayer *)self.layer setPlayer:self.player];
}

- (void)addPlayerItemTimeObserver {
    self.timeObserver = [self.queuePlayer
                         addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                         queue:dispatch_get_main_queue()
                         usingBlock:self.timePeriodBlock];
}

@end
