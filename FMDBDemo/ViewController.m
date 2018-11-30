//
//  ViewController.m
//  FMDBDemo
//
//  Created by 李永杰 on 2018/9/17.
//  Copyright © 2018年 muheda. All rights reserved.
//

#import "ViewController.h"
#import "MDDB.h"
#import "Person.h"
#import "User.h"
@interface ViewController ()
@property (nonatomic,strong) NSTimer *timer0;
@property (nonatomic,strong) NSTimer *timer1;
@property (nonatomic,strong) MDDB *db;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _db = [MDDB shareDatabase:@"user.db"];

    Person *person = [[Person alloc]init];
    person.name = @"张三";
    person.phoneNumber = @(18792893311);
    person.luckyNum = 7;
    person.height = 170.0;
    person.map = @"北京";
    
    Person *person0 = [Person new];
    person0.name = @"莉丝";
    person0.phoneNumber = @(1331111111);
    person0.luckyNum = 3;
    person0.height = 172.0;
    person0.city = @"沈阳";
    person0.weight = 140;
    person0.demo = @"这是一demo";
    person0.sex = @"女";
    person0.age = 13;
    
    Person *person1 = [Person new];
    person1.name = @"王武";
    person1.phoneNumber = @(1331112291);
    person1.luckyNum = 3;
    person1.height = 172.0;
    person1.city = @"沈阳";
    person1.weight = 140;
    person1.sex = @"女";
    person1.age = 15;
   
    Person *person3 = [Person new];
    person3.name = @"找刘";
    person3.phoneNumber = @(1441111111);
    person3.luckyNum = 9;
    person3.height = 180.0;
    person3.city = @"郑州";
    person3.weight = 120;
    person3.demo = @"不是一个demo";
    person3.sex = @"女";
    person3.age = 18;
    
    Person *person4 = [Person new];
    person4.name = @"网吧";
    person4.phoneNumber = @(134511111);
    person4.luckyNum = 3;
    person4.height = 173.0;
    person4.city = @"徐州";
    person4.weight = 140;
    person4.demo = @"随时准备着";
    person4.sex = @"男";
    person4.age = 20;

    User *user0 = [User new];
    user0.name = @"哈咯";
    user0.sex = @"男";
    user0.city = @"北京";
    user0.height = 176.0;
    user0.weight = 130;
    user0.age = 16;
    
    User *user1 = [User new];
    user1.name = @"西湖";
    user1.sex = @"男";
    user1.city = @"焦作";
    user1.height = 180.0;
    user1.weight = 140;
    user1.age = 18;
    
    User *user2 = [User new];
    user2.name = @"嗯嗯";
    user2.sex = @"女";
    user2.city = @"成都";
    user2.height = 166.0;
    user2.weight = 100;
    user2.age = 17;
    
    //创建表
    
//    BOOL s1 = [_db md_createTable:@"person" dicOrModel:person0 excludeName:@[@"sex",@"age",@"demo"]];
//    BOOL s2 = [_db md_createTable:@"user" dicOrModel:user0 excludeName:nil];
//    NSLog(@"%d%d",s1,s2);
#pragma mark 数据操作
//    //插入数据
//    NSArray *arr1 = @[person,person0,person1,person3,person4];
//    [_db md_insertTable:@"person" dicOrModelArray:arr1 success:^(int result) {
//        NSLog(@"%@",result?@"成功":@"失败");
//    }];
//
//    NSArray *arr2 = @[user0,user1,user2];
//    [_db md_insertTable:@"user" dicOrModelArray:arr2 success:^(int result) {
//        NSLog(@"%@",result?@"成功":@"失败");
//    }];
    //删除数据
//    [db md_deleteTable:@"person" whereFormat:@"where mid > 3"];
//    [db md_deleteAllDataFromTable:@"person"];
    //更新数据
//    NSLog(@"%@",[db md_updateTable:@"person" dicOrModel:@{@"map":@"郑州"} whereFormat:@"WHERE mid = 2"]?@"success":@"fail");
 
    //查询数据
    //根据height从低到高
//    NSArray *arr = [_db md_queryTable:@"person" dicOrModel:@{@"name":@"TEXT",@"height":@"INTEGER",@"city":@"text"} whereFormat:@"group by name order by height asc"];
    NSArray *arr = [_db md_queryMutilTable:@[@"person",@"user"] dic:@{@"phoneNumber":@"INTEGER",@"luckyNum":@"INTEGER",@"weight":@"INTEGER",@"city":@"TEXT"} whereFormat:@"person.mid = user.mid"];
    NSLog(@"%@",arr);
//    NSArray *arr = [db md_queryTable:@"person" dicOrModel:person4 whereFormat:@"where map = '郑州'"];
//    NSLog(@"%@",arr);
#pragma mark 表操作
    //删除表
//    [db md_deleteTable:@"person"];
    //是否存在表
//    NSLog(@"%@",[db md_isExistTable:@"person"]?@"存在person":@"不存在person");
//    NSLog(@"%@",[db md_isExistTable:@"user"]?@"存在user":@"不存在user");
    //表中有n条记录
//    NSLog(@"%d",[db md_numberOfTable:@"person"]);
//    NSLog(@"%d",[db md_numberOfTable:@"user"]);
    //表中的字段
//    NSLog(@"%@",[db md_columnNameArray:@"person"]);
//    NSLog(@"%@",[db md_columnNameArray:@"user"]);
    //升级
    //增加字段
//    NSLog(@"%@",[db md_alterTable:@"person" dicOrModel:@{@"password":@"TEXT"} excludeName:@[@"sex",@"age",@"demo"]]?@"增加成功":@"增加失败");
//    NSLog(@"%@",[db md_addCoumnOfTable:@"person" dicOrModel:[Person class] excludeName:@[@"sex",@"age",@"demo"]]?@"success":@"fail");
//    NSLog(@"%@",[db md_alterTableName:@"personone" withTableStr:@"person"]?@"success":@"fail");

    //删除字段
//        [db md_deleteTable:@"person" dicOrModel:person4 withStr:@[@"city",@"name",@"sex",@"age",@"demo",@"year",@"date",@"contry"]];

    //修改字段
//    [db md_alterColumnOfTable:@"person" oldColumn:@"phone" newColumn:@"phoneNumber" newColumnType:@"INTEGER" dicOrModel:[Person class] excludeArr:@[@"sex",@"age",@"demo"]];
#pragma mark - 事务
//    [db md_inTransaction:^(BOOL *rollback) {
//
//        //只要有一次不成功,则进行回滚操作
//        BOOL flag0 = [db md_insertTable:@"person" dicOrModel:person];
//        BOOL flag1 = [db md_insertTable:@"person" dicOrModel:nil];//造成错误操作
//        BOOL flag2 = [db md_insertTable:@"person" dicOrModel:person];
//
//        if (!flag0 || !flag1 || !flag2) {
//            *rollback = YES;
//            return;
//        }
//    }];
#pragma mark - 多线程
//    _timer0 = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timer0Action) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop]addTimer:_timer0 forMode:NSRunLoopCommonModes];
//
//    _timer1 = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timer1Action) userInfo:nil repeats:YES];
//
//    [[NSRunLoop mainRunLoop]addTimer:_timer1 forMode:NSRunLoopCommonModes];
    
}
-(void)timer0Action {
    __weak typeof(self) weakSelf = self;
    [_db md_inDatabase:^{
    NSLog(@"%@",[weakSelf.db md_updateTable:@"person" dicOrModel:@{@"city":@"安阳"} whereFormat:@"where mid = 1"]?@"YES":@"NO");
    }];
}
-(void)timer1Action {
    __weak typeof(self) weakSelf = self;
    [_db md_inDatabase:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"%@",[weakSelf.db md_updateTable:@"person" dicOrModel:@{@"city":@"许昌"} whereFormat:@"where mid = 1"]?@"YES":@"NO");
            
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [_timer0 invalidate];
    [_timer1 invalidate];
}

@end
