//
//  User.h
//  FMDBDemo
//
//  Created by 李永杰 on 2018/9/18.
//  Copyright © 2018年 muheda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic,copy)NSString      *name;
@property (nonatomic,copy)NSString      *city;
@property (nonatomic,assign)NSInteger   height;
@property (nonatomic,assign)NSInteger   weight;
@property (nonatomic,copy)NSString      *sex;
@property (nonatomic,assign)NSInteger   age;
@end
