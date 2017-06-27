//
//  YLPlayerMutiplePresenter.m
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/27.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "YLPlayerMutiplePresenter.h"
#import "YLPlayerView.h"

static const NSString *PlayerMutiplePresenterPlayerItemStatusContext;

@interface YLPlayerMutiplePresenter ()

@property (nonatomic, readwrite, strong) YLPlayerView *playerView;
@property (nonatomic, copy) TimePeriodBlock timePeriodBlock;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, readwrite, weak) id<YLPlayerMutiplePresenterDelegate> delegate;

@end

@implementation YLPlayerMutiplePresenter

- (instancetype)initWithFrame:(CGRect)frame
          videoURLStringArray:(NSArray *)urlStringArray
              timePeriodBlock:(TimePeriodBlock)block
                containerView:(UIView *)containerView
                     delegate:(id<YLPlayerMutiplePresenterDelegate>)delegate {
    self = [super init];
    if (self) {
        _playerView = [[YLPlayerView alloc] initWithFrame:frame videoURLStringArray:urlStringArray];
        _timePeriodBlock = block;
        [self addPlayerItemTimeObserver];
        [self setUpKVO];
        [self setUpNotification];
        
        if (containerView) {
            [containerView addSubview:_playerView];
        }
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserver) {
        [self.playerView.queuePlayer removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)addPlayerItemTimeObserver {
    _timeObserver = [_playerView.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                          queue:dispatch_get_main_queue()
                                                                     usingBlock:_timePeriodBlock];
}

- (void)setUpKVO {
    [_playerView.queuePlayer addObserver:self
                              forKeyPath:@"status"
                                 options:NSKeyValueObservingOptionNew
                                 context:&PlayerMutiplePresenterPlayerItemStatusContext];
}

- (void)setUpNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (NSInteger)getTotalSeconds {
    if (self.playerView.queuePlayer && self.playerView.queuePlayer.items) {
        NSInteger totalSeconds = 0;
        for (AVPlayerItem *item in self.playerView.queuePlayer.items) {
            totalSeconds += (NSInteger)CMTimeGetSeconds(item.asset.duration);
        }
        return totalSeconds;
    }
    return 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != &PlayerMutiplePresenterPlayerItemStatusContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        if (self.playerView.queuePlayer) {
            if (self.playerView.queuePlayer.status == AVPlayerStatusReadyToPlay) {
                NSInteger totalSeconds = [self getTotalSeconds];
                if (self.delegate && [self.delegate respondsToSelector:@selector(playerWillPlay:totalDuration:)]) {
                    [self.delegate playerWillPlay:self totalDuration:totalSeconds];
                }
                [self.playerView.queuePlayer play];
            }
        }
    }
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    if (!self.playerView.queuePlayer.items || self.playerView.queuePlayer.items.count <= 0) {
        return;
    }
    NSInteger currentDuration = (NSInteger)CMTimeGetSeconds(self.playerView.queuePlayer.items.firstObject.asset.duration);
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidEndOneVideo:currentDuration:)]) {
        [self.delegate playerDidEndOneVideo:self currentDuration:currentDuration];
    }
}

@end
