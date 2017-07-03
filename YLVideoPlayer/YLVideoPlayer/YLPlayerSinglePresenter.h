//
//  YLPlayerSinglePresenter.h
//  YLVideoPlayer
//
//  Created by yangli on 2017/6/27.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YLVideoPlayerDefinitions.h"

@interface YLPlayerSinglePresenter : NSObject

- (instancetype)initWithFrame:(CGRect)frame
               videoURLString:(NSString *)urlString
              timePeriodBlock:(TimePeriodBlock)block
                containerView:(UIView *)containerView
                     delegate:(id<YLPlayerSinglePresenterDelegate>)delegate;

@end
