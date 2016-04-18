//
//  CoreDataManager.h
//  CoreDataDemo
//
//  Created by lzxuan on 15/9/29.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
//把 官方自带的CoreData 封装 进行增删改查
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject
//CoreData 上下文
@property (nonatomic,strong) NSManagedObjectContext *context;
//单例函数
+ (instancetype)sharedManager;
//增删改查

#pragma mark - 增加
- (void)insertDataWithName:(NSString *)name
                     score:(double)score
                 headimage:(NSData *)headimage;
#pragma mark - 删除
//根据名字删除
- (void)deleteDataWithName:(NSString *)name;
#pragma mark - 修改
//根据名字修改其他数据
- (void)updateDataWithName:(NSString *)name
                     score:(double)score
                 headimage:(NSData *)headimage;
#pragma mark - 查找
- (NSArray *)fetchDataWithName:(NSString *)newName;


@end






