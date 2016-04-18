//
//  CoreDataManager.m
//  CoreDataDemo
//
//  Created by lzxuan on 15/9/29.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "CoreDataManager.h"

#import "StudentModel.h"

@implementation CoreDataManager

//单例函数
+ (instancetype)sharedManager {
    static CoreDataManager *manager = nil;
    @synchronized(self) {
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    }
    return manager;
}
//初始化数据库  ->一旦 获取 管理对象 数据库就应该 创建好了，应该在初始化函数进行
/*
 1.创建 数据模型 文件
 2.根据数据模型 文件 设计 model
 3.初始化 CoreData
    3.1 #import <CoreData/CoreData.h>
    3.2 获取数据模型文件(沙盒包内)
        MyData.xcdatamodeld在沙盒包内 叫做MyData.momd
    3.3 根据数据模型文件 实例化 存储协调器
    3.4 创建数据库sqlite 类型的文件
    3.5 创建上下文管理对象 关联 协调器
 
    3.6 通过上下文 进行 数据库的增删改查
 */
- (instancetype)init {
    if (self = [super init]) {
        //1.获取 数据模型文件 路径
#if 0
        //方法1//  MyData.xcdatamodeld在沙盒包内中变成 xx.momd
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MyData" ofType:@"momd"];
        NSManagedObjectModel *modelFile = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
#else
        //获取沙盒包内 中 所有的xxx.xcdatamodeld数据模型 文件
        NSManagedObjectModel *modelFile = [NSManagedObjectModel mergedModelFromBundles:nil];
#endif
        //2.实例化 存储协调器 管理数据模型文件
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:modelFile];
        //2.1协调器 增加 存储类型  数据库
        NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/data.sqlite"];
        //NSSQLiteStoreType  sqlite 数据类型
        NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:path] options:nil error:nil];
        if (!store) {
            NSLog(@"创建数据库失败");
        }
        //3.创建上下文
        self.context = [[NSManagedObjectContext alloc] init];
        //设置 管理协调器
        self.context.persistentStoreCoordinator = coordinator;
    }
    return self;
}
//增删改查

#pragma mark - 增加
- (void)insertDataWithName:(NSString *)name
                     score:(double)score
                 headimage:(NSData *)headimage {
    //使用CoreData 的时候 模型不能按照下面的形式创建 会崩溃
//    StudentModel *model = [[StudentModel alloc] init];
//    model.name = @"xxx";
    // 上下文管理对象 通过 NSEntityDescription  来向数据库 动态增加一个数据模型对象StudentModel
    //NSEntityDescription  内部 会动态为 数据模型增加setter和getter方法
    
    StudentModel *model = (StudentModel *)[NSEntityDescription insertNewObjectForEntityForName:@"StudentModel" inManagedObjectContext:self.context];
    //赋值
    model.name = name;
    model.score = @(score);
    model.headimage = headimage;
    
    //上面 是 对内存做了增加
    //保存到本地磁盘数据库   （增删改 都要对数据库进行保存 才能写入磁盘）
    [self saveDataWithType:@"insert"];
}
- (void)saveDataWithType:(NSString *)type {
    NSError *error = nil;
    BOOL ret = [self.context save:&error];
    if (!ret) {//保存失败
        NSLog(@"%@ error:%@",type,error.localizedDescription);
    }
}

#pragma mark - 删除
//根据名字删除
- (void)deleteDataWithName:(NSString *)name {
    //先找再删除
    NSArray *arr = [self fetchDataWithName:name];
    //遍历
    for (StudentModel *model  in arr) {
        //从内存数据删除
        [self.context deleteObject:model];
    }
    //保存 同步到本地磁盘
    [self saveDataWithType:@"delete"];
}
#pragma mark - 修改
//根据名字修改其他数据
- (void)updateDataWithName:(NSString *)name
                     score:(double)score
                 headimage:(NSData *)headimage {
    //先找再修改
    NSArray *arr = [self fetchDataWithName:name];
    //遍历
    for (StudentModel *model  in arr) {
        //直接修改找到的model  这些model 都在数据库内存中
        model.score = @(score);
        model.headimage = headimage;
    }
    //保存 同步到本地磁盘
    [self saveDataWithType:@"update"];
}
#pragma mark - 查找
//根据名字找
- (NSArray *)fetchDataWithName:(NSString *)newName {
    
    //创建一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置 要查询的实体(数据模型) 向哪一类数据模型进行查询
    request.entity = [NSEntityDescription entityForName:@"StudentModel" inManagedObjectContext:self.context];
    
    if (newName) {
        //设置谓词 根据过滤条件来查找
        //@"name like xiaohong"--->谓词 去 StudentModel 的对象 中 找属性名是name 的属性 的值 是不是xiaohong
        //@"score like 100"
#if 0
         //模糊查询  要分开写条件 '*xiaohong*'
        NSString * str = [NSString stringWithFormat:@"name like '*%@*'",newName];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
#else
        //设置谓词 -》过滤查询
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@",newName];
#endif
        request.predicate = predicate;
    }
    //设置排序准则(如果要想排序 需要设置排序准则)
    //按照分数降序排  key 就是对象的属性名
    NSSortDescriptor*sort1 = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO];
    NSSortDescriptor*sort2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    //先按照sort1排序 如果score 有相同的再按照sort2排
    request.sortDescriptors = @[sort1,sort2];
    
    //没有设置谓词的话 表示查询所有的StudentModel
    
    //执行 查询请求 返回一个数组
    NSArray *arr = [self.context executeFetchRequest:request error:nil];
    return arr;
}
@end







