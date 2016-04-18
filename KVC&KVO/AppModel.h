//
//  AppModel.h
//  KVC&KVO
//
//  Created by LZXuan on 15-6-1.
//  Copyright (c) 2015年 轩哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppModel : NSObject
{
    NSInteger _age;
    NSString *_name;
}
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,copy) NSString *name;

- (void)addObject:(id)obj;

- (void)changeName;

- (NSString *)funName;
@end
