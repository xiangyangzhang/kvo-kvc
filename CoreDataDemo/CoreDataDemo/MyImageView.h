//
//  MyImageView.h
//  CoreDataDemo
//
//  Created by lzxuan on 15/9/28.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyImageView : UIImageView
//target  - action  ---》代理设计模式
- (void)addTarget:(id)target action:(SEL)action;

@end
