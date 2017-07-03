//
//  YLPlayerSinglePresenter.m
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/27.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "YLPlayerSinglePresenter.h"
#import "YLPlayerView.h"

static const NSString *PlayerSinglePresenterPlayerItemStatusContext;

@interface YLPlayerSinglePresenter ()

@property (nonatomic, readwrite, strong) YLPlayerView *playerView;
@property (nonatomic, copy) TimePeriodBlock timePeriodBlock;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, readwrite, weak) id<YLPlayerSinglePresenterDelegate> delegate;

@end

@implementation YLPlayerSinglePresenter

- (instancetype)initWithFrame:(CGRect)frame
               videoURLString:(NSString *)urlString
              timePeriodBlock:(TimePeriodBlock)block
                containerView:(UIView *)containerView
                     delegate:(id<YLPlayerSinglePresenterDelegate>)delegate {
    self = [super init];
    if (self) {
        _playerView = [[YLPlayerView alloc] initWithFrame:frame videoURLString:urlString];
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
    [self removeKVO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserver) {
        [self.playerView.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

#pragma mark - private method
- (void)addPlayerItemTimeObserver {
    self.timeObserver = [_playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                     queue:dispatch_get_main_queue()
                                                                usingBlock:_timePeriodBlock];
}

- (void)setUpKVO {
    [self.playerView.player addObserver:self
                             forKeyPath:@"status"
                                options:NSKeyValueObservingOptionNew
                                context:&PlayerSinglePresenterPlayerItemStatusContext];
    
    [self.playerView.player addObserver:self
                             forKeyPath:@"loadedTimeRanges"
                                options:NSKeyValueObservingOptionNew
                                context:&PlayerSinglePresenterPlayerItemStatusContext];
    
    [self.playerView.player addObserver:self
                             forKeyPath:@"playbackBufferEmpty"
                            options:NSKeyValueObservingOptionNew
                            context:&PlayerSinglePresenterPlayerItemStatusContext];
    
    [self.playerView.player addObserver:self
                         forKeyPath:@"playbackLikelyToKeepUp"
                            options:NSKeyValueObservingOptionNew
                            context:&PlayerSinglePresenterPlayerItemStatusContext];
}

- (void)setUpNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)removeKVO {
    [self.playerView.player removeObserver:self forKeyPath:@"status"];
    [self.playerView.player removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerView.player removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerView.player removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != &PlayerSinglePresenterPlayerItemStatusContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        if (self.playerView.player) {
            if (self.playerView.player.status == AVPlayerStatusReadyToPlay) {
                NSInteger duration = (NSInteger)CMTimeGetSeconds(self.playerView.player.currentItem.asset.duration);
                if (self.delegate && [self.delegate respondsToSelector:@selector(playerWillPlay:duration:)]) {
                    [self.delegate playerWillPlay:self duration:duration];
                }
                [self.playerView.player play];
            }
        }
    }
}

#pragma mark - event handler
- (void)moviePlayDidEnd:(NSNotification *)notification {
}

@end
