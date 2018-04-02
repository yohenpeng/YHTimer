//
//  YHTimer.h
//  learnObjective-C
//
//  Created by peng yihan on 2018/3/30.
//  Copyright © 2018年 peng yihan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,YHTimerRunLoopMode){
    YHTimerDefaultMode,
    YHTimerCommonMode,
    YHTimerTrackingMode
};

typedef void(^YHTimeOutFireAction)(void);

@interface YHTimer : NSObject

+(YHTimer *)startTimer:(NSTimeInterval)interval runloopMode:(YHTimerRunLoopMode)mode timeOutFireAction:(YHTimeOutFireAction)action;

-(void)stop;

@end

