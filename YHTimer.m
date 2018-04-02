//
//  YHTimer.m
//  learnObjective-C
//
//  Created by peng yihan on 2018/3/30.
//  Copyright © 2018年 peng yihan. All rights reserved.
//

#import "YHTimer.h"
#import <UIKit/UIKit.h>

@interface YHTimerManager : NSObject
@property(strong,nonatomic)NSMutableDictionary<NSString*,NSTimer*> *timerDic;  //key为@(interval)##@(mode)
@property(strong,nonatomic)NSMutableDictionary<NSString*,YHTimeOutFireAction> *timeOutAcitonDic; //key为@(interval)##@(mode)##@(timerId)
@property(assign,nonatomic)NSInteger timerIndex;  //timerId递增

+(instancetype)shareManager;
-(NSString *)startTimer:(NSTimeInterval)interval runloopMode:(YHTimerRunLoopMode)mode timeOutFireAction:(YHTimeOutFireAction)action;
-(void)stopTimer:(NSString *)timerId;

@end


@implementation YHTimerManager

+(instancetype)shareManager{
    static YHTimerManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YHTimerManager alloc]init];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.timerIndex = 0;
        self.timerDic = [NSMutableDictionary new];
        self.timeOutAcitonDic = [NSMutableDictionary new];
    }
    return self;
}

-(NSString *)startTimer:(NSTimeInterval)interval runloopMode:(YHTimerRunLoopMode)mode timeOutFireAction:(YHTimeOutFireAction)action{
    self.timerIndex ++;
    NSString *timerKey = [NSString stringWithFormat:@"%0.2f##%ld",interval,(long)mode];
    NSTimer *timer = [self.timerDic objectForKey:timerKey];
    if (timer == nil) {
        timer = [self createTimer:interval runloopMode:mode timerKey:timerKey];
        [self.timerDic setObject:timer forKey:timerKey];
    }
    
    NSString *timerId = [NSString stringWithFormat:@"%@##%ld",timerKey,self.timerIndex];
    [self.timeOutAcitonDic setObject:[action copy] forKey:timerId];
    return timerId;
}

-(NSTimer *)createTimer:(NSTimeInterval)interval runloopMode:(YHTimerRunLoopMode)mode timerKey:(NSString *)timerKey{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timeOut:) userInfo:timerKey repeats:YES];
    if (mode == YHTimerCommonMode) {
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }else if(mode == YHTimerTrackingMode){
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    }
    NSLog(@"[YHTimerManager createTimer] interval:%0.2f,mode:%@",interval,[self runloopModeString:mode]);
    return timer;
}

-(NSString *)runloopModeString:(YHTimerRunLoopMode)mode{
    if(mode == YHTimerCommonMode) {
        return @"YHTimerCommonMode";
    }else if(mode == YHTimerDefaultMode){
        return @"YHTimerDefaultMode";
    }else if(mode == YHTimerTrackingMode){
        return @"YHTimerTrackingMode";
    }
    return @"";
}

-(void)dismissTimer:(NSTimer *)timer key:(NSString *)timerKey{
    [timer invalidate];
    timer = nil;
    NSArray *array = [timerKey componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"##"]];
    NSTimeInterval interval = [[array objectAtIndex:0] doubleValue];
    YHTimerRunLoopMode mode = (YHTimerRunLoopMode)[[array objectAtIndex:1] integerValue];
    NSLog(@"[YHTimerManager dismissTimer] interval:%0.2f,mode:%@",interval,[self runloopModeString:mode]);
}

-(void)timeOut:(NSTimer*)timer{
    NSString *timeKey = timer.userInfo;
    BOOL timerIsUsing = NO;
    for (NSString *item in self.timeOutAcitonDic.allKeys) {
        if ([item hasPrefix:timeKey]) {
            YHTimeOutFireAction action = [self.timeOutAcitonDic objectForKey:item];
            if (action) {
                timerIsUsing = YES;
                action();
            }
        }
    }
    
    if (timerIsUsing == NO) {
        [self.timerDic removeObjectForKey:timeKey];
        [self dismissTimer:timer key:timeKey];

    }
}

-(void)stopTimer:(NSString *)timerId{
    [self.timeOutAcitonDic removeObjectForKey:timerId];
}

@end


@interface YHTimer ()
@property(nonatomic,copy)NSString *timerId;
@end

@implementation YHTimer

+(YHTimer *)startTimer:(NSTimeInterval)interval runloopMode:(YHTimerRunLoopMode)mode timeOutFireAction:(YHTimeOutFireAction)action{
    YHTimer *timer = [[YHTimer alloc]init];
    timer.timerId = [[YHTimerManager shareManager] startTimer:interval runloopMode:mode timeOutFireAction:action];
    return timer;
}

-(void)stop{
    [[YHTimerManager shareManager] stopTimer:self.timerId];
}

@end
