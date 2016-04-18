//
//  AppModel.m
//  KVC&KVO
//
//  Created by LZXuan on 15-6-1.
//  Copyright (c) 2015年 轩哥. All rights reserved.
//

#import "AppModel.h"

@implementation AppModel
/*
 kvc 之前 会检测调用 是否可以访问 成员变量
 //默认返回YES --》可以访问
 如果 返回no kvc 就不能直接访问 成员变量了
 */
//+ (BOOL)accessInstanceVariablesDirectly {
//    return NO;
//}

// 可以重写  是否 允许 对象 的属性 被 kvo 进行 监听
//这个方法可以对所有的属性 进行设置 key 就是属性名
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    /*
    if ([key isEqualToString:@"name"]) {
        return NO;
    }*/
    //返回yes 可以被监听到 no 不可以
    //默认是yes
    return YES;
}
//下面两个方法是对 单个 属性设置
/*
+ (BOOL)automaticallyNotifiesObserversOfName {
    return YES;
}*/
/*
+ (BOOL)automaticallyNotifiesObserversOfDataArr {
    return YES;
}*/

- (instancetype)init {
    if (self = [super init]) {
        self.dataArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addObject:(id)obj {
#if 1
    //向数组 增加元素 这时 修改数组元素 是不能触发 kvo
    //我们 手动触发kvo
    [self willChangeValueForKey:@"dataArr"];
    [self.dataArr addObject:obj];
    [self didChangeValueForKey:@"dataArr"];
#else
    //先 通过 kvc 获取 值 然后再 addObject  也可以被kvo 监听
    [[self mutableArrayValueForKeyPath:@"dataArr"] addObject:obj];
    
#endif
}



- (void)changeName {
#if 0
    // 不能被监听到
    _name = @"changeName";
#else
    //默认是只有 setter 和kvc  才能触发 kvo
    //但是我们也可以 手动让其触发kvo
    
    [self willChangeValueForKey:@"name"];
    _name = @"changeName";
    [self didChangeValueForKey:@"name"];
#endif
}


- (NSString *)funName {
    return _name;
}
//可以防止 崩溃 kvc 赋值的时候如果找不到对应的key 会调用 下面的方法
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

}
//kvc 防止 获取值的时候 找不到key 崩溃，
//kvc  获取值的时候 如果找不key 那么会调用下面的方法
- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}
@end


