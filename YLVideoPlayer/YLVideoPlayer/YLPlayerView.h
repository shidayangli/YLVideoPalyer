//
//  YLPlayerView.h
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/26.
//  Copyright © 2017年 yangli. All rights reserved.
//

@class AVPlayer, AVPlayerItem, AVQueuePlayer;

#import <UIKit/UIKit.h>

#import "YLVideoPlayerDefinitions.h"

@interface YLPlayerView : UIView

@property (nonatomic, readonly, strong) AVPlayer *player;
@property (nonatomic, readonly, strong) AVQueuePlayer *queuePlayer;

- (instancetype)initWithFrame:(CGRect)frame videoURLString:(NSString *)urlString;

- (instancetype)initWithFrame:(CGRect)frame videoURLStringArray:(NSArray *)urlStringArray;

- (NSInteger)getTotalSeconds;

@end
