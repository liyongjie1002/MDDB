//
//  Person.h
//  FMDBDemo
//
//  Created by 李永杰 on 2018/9/17.
//  Copyright © 2018年 muheda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
@property (nonatomic,copy)NSString      *name;
@property (nonatomic,strong)NSNumber    *phoneNumber;
@property (nonatomic,assign)NSInteger   luckyNum;
@property (nonatomic,assign)float       height;
@property (nonatomic,strong)NSString    *city;
@property (nonatomic,assign)float       weight;
@property (nonatomic,assign)NSString    *demo;
@property (nonatomic,strong)NSString    *map;
@property (nonatomic,copy)NSString      *sex;
@property (nonatomic,assign)NSInteger   age;
@property (nonatomic,copy) NSString     *year;
@property (nonatomic,copy) NSString     *date;
@property (nonatomic,copy) NSString     *address;
@property (nonatomic,copy) NSString     *contry;
@end
