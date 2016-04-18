//
//  MyImageView.m
//  CoreDataDemo
//
//  Created by lzxuan on 15/9/28.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "MyImageView.h"
@interface MyImageView ()
@property (nonatomic,weak) id target;//弱引用指针
@property (nonatomic,assign) SEL action;
@end
@implementation MyImageView
- (void)addTarget:(id)target action:(SEL)action {
    //图片默认是不能和用户交互的
    //1.先打开用户交互
    self.userInteractionEnabled = YES;
    //保存target action
    //触摸图片的时候才执行 target ->action;
    self.target = target;
    self.action = action;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//触摸 离开屏幕触发
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //委托 target 调用 action
    if ([self.target respondsToSelector:self.action]) {
        [self.target performSelector:self.action withObject:self];
    }
}
#pragma clang diagnostic pop

@end



