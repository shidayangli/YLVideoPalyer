//
//  YLVideoPlayerDefinitions.h
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/27.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <CoreMedia/CMTime.h>

#ifndef YLVideoPlayerDefinitions_h
#define YLVideoPlayerDefinitions_h

typedef void(^TimePeriodBlock)(CMTime time);
@class YLPlayerMutiplePresenter;

@protocol YLPlayerMutiplePresenterDelegate <NSObject>

@optional
- (void)playerWillPlay:(YLPlayerMutiplePresenter *)presenter totalDuration:(NSInteger)duration;
- (void)playerDidEndOneVideo:(YLPlayerMutiplePresenter *)presenter currentDuration:(NSInteger)duration;

@end

#endif /* YLVideoPlayerDefinitions_h */
