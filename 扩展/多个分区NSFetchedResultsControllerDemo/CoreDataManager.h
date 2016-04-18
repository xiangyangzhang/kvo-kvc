//
//  CoreDataManager.h
//  NSFetchedResultsControllerDemo
//
//  Created by LZXuan on 14-9-25.
//  Copyright (c) 2014年 LZXuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface CoreDataManager : NSObject
@property (nonatomic,readonly)  NSManagedObjectContext *objContext;


//单例
+(CoreDataManager *)shareManager;
//保存
- (void)saveContext;
//添加数据
- (void)insertDataWithModel:(id)model;
//修改数据
- (void)updataModelWithPer:(NSString *)perstring andObjAge:(id)model;

//删除数据
- (void)deleteModelWithPerstring:(NSString *)per;

//获取全部数据
- (NSArray *)fetchAllData;
@end
