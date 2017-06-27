//
//  YLPlayerMutiplePresenter.h
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/27.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YLVideoPlayerDefinitions.h"

@class YLPlayerView;

@interface YLPlayerMutiplePresenter : NSObject

@property (nonatomic, readonly, strong) YLPlayerView *playerView;

- (instancetype)initWithFrame:(CGRect)frame
          videoURLStringArray:(NSArray *)urlStringArray
              timePeriodBlock:(TimePeriodBlock)block
                containerView:(UIView *)containerView
                     delegate:(id<YLPlayerMutiplePresenterDelegate>)delegate;

@end
