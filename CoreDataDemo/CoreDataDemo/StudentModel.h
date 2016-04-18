//
//  StudentModel.h
//  CoreDataDemo
//
//  Created by lzxuan on 15/9/29.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StudentModel : NSManagedObject

@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * headimage;

@end
