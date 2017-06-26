//
//  YLPlayerView.h
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/26.
//  Copyright © 2017年 yangli. All rights reserved.
//

@class AVPlayer, AVPlayerItem;

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>

typedef void(^TimePeriodBlock)(CMTime time);

@interface YLPlayerView : UIView

@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) AVPlayerItem *currentItem;

- (instancetype)initWithFrame:(CGRect)frame videoURLString:(NSString *)urlString timePeriodBlock:(TimePeriodBlock)block;

@end
