//
//  MDDB.h
//
//  Created by muheda on 18/8/18.
//

#import <Foundation/Foundation.h>

@interface MDDB : NSObject

#pragma mark - 创建数据库

/**
 单例方法创建数据库

 @param dbName 数据库名
 @return 单例
 */
+ (instancetype)shareDatabase:(NSString *)dbName;

/**
 单例方法创建数据库，自定义路径

 @param dbName 数据库名
 @param dbPath 数据库存储路径
 @return 单例
 */
+ (instancetype)shareDatabase:(NSString *)dbName path:(NSString *)dbPath;

#pragma mark - ------------------------------------DDL-----------------------------------------
#pragma mark 创建表
/**
 创建表

 @param tableName 表名
 @param parameters 字典或model
 @param nameArr 不允许model或dic里的属性/key生成表的字段,如:nameArr = @[@"name"],则不允许创建名为name的属性/key表字段
 @return 是否创建成功
 */
- (BOOL)md_createTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr;
#pragma mark 删除表
/**
 删除表

 @param tableName 表名
 @return 是否删除成功
 */
- (BOOL)md_deleteTable:(NSString *)tableName;
#pragma mark 是否存在表
/**
 是否存在表

 @param tableName 表名
 @return 存在与否
 */
- (BOOL)md_isExistTable:(NSString *)tableName;
#pragma mark n条记录
/**
 表中共有多少条数据

 @param tableName 表名
 @return n条记录
 */
- (int)md_numberOfTable:(NSString *)tableName;
#pragma mark 所有字段
/**
 返回表中的所有字段名

 @param tableName 表名
 @return 所有字段组成的数组
 */
- (NSArray *)md_columnNameArray:(NSString *)tableName;
#pragma mark 增加字段
/**
 增加字段

 @param tableName 表名
 @param parameters 字典或model
 @param nameArr 不生成的字段，和创建表时一致，中间有创建新表的过程，确保保持字段一致
 @return 成功与否
[db md_alterTable:@"person" dicOrModel:@{@"password":@"TEXT"} excludeName:@[@"sex",@"age",@"demo"]
 */
- (BOOL)md_addCoumnOfTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr;
#pragma mark 重命名表
/**
 重命名表

 @param tableName 表名
 @param tableStr 新的表名
 @return 成功与否
 */
-(BOOL)md_alterTableName:(NSString *)tableName withTableStr:(NSString *)tableStr;
#pragma mark 删除字段
/**
 删除字段，sqlite不支持直接删除字段

 @param tableName 表名
 @param parameters 字典或model
 @param arr 要删除的字段数组，加上创建表时的exclude数组，中间有创建新表的过程，确保保持字段一致
 @return 成功与否
 */
-(BOOL)md_deleteTable:(NSString *)tableName dicOrModel:(id)parameters withStr:(NSArray *)arr;
#pragma mark 修改字段名
/**
 修改字段名，sqlite不支持修改字段

 @param tableName 表名
 @param oldColumn 老字段名
 @param newColumn 新字段名
 @param newColumnType 新字段类型
 @param dicOrModel 字典或model
 @param excludeArr 不生成的字段,加上创建表时的exclude数组，中间有创建新表的过程，确保保持字段一致
 */
-(void)md_alterColumnOfTable:(NSString *)tableName oldColumn:(NSString *)oldColumn newColumn:(NSString *)newColumn newColumnType:(NSString *)newColumnType dicOrModel:(id)dicOrModel excludeArr:(NSArray *)excludeArr;

#pragma mark - ------------------------------------DML-----------------------------------------
#pragma mark 增
/**
 插入数据

 @param tableName 表名
 @param parameters 字典或model
 @return 是否插入数据成功
 */
- (BOOL)md_insertTable:(NSString *)tableName dicOrModel:(id)parameters;
/**
 插入一组数据,其中一条数据出错，就回滚
 
 @param tableName 表名
 @param dicOrModelArray 一组数据
 @param block 回调成功与否
 */
- (void)md_insertTable:(NSString *)tableName dicOrModelArray:(NSArray *)dicOrModelArray success:(void (^)(int))block;

#pragma mark 删

/**
 根据条件删除表中数据

 @param tableName 表名
 @param format 条件
 @return 删除成功与否
 */
- (BOOL)md_deleteTable:(NSString *)tableName whereFormat:(NSString *)format, ...;

/**
 清空表中数据

 @param tableName 表名
 @return 清空数据成功与否
 */
- (BOOL)md_deleteAllDataFromTable:(NSString *)tableName;

#pragma mark 改

/**
 根据条件更改表中数据，直接用model替换整个记录，或者用字典替换某几个字段

 @param tableName 表名
 @param parameters 字典或model
 @param format 条件
 @return 成功与否
 [db md_updateTable:@"person" dicOrModel:@{@"map":@"郑州"} whereFormat:@"WHERE mid = 2"]
 */
- (BOOL)md_updateTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...;

#pragma mark 查

/**
 根据条件查找表中数据

 @param tableName 表名
 @param parameters 字典或model,字典：要查询的字段，model：所有字段
 @param format 条件
 @return 查询的数据
 */
- (NSArray *)md_queryTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...;

/**
 根据条件查询多个表中的数据

 @param tableNames 多个表
 @param parameters 要查询的字段
 @param format 条件
 @return 查询结果
 */
- (NSArray *)md_queryMutilTable:(NSArray *)tableNames dic:(id)parameters whereFormat:(NSString *)format, ...;
#pragma mark - 数据库开关

/**
 关闭数据库
 */
- (void)close;

/**
 打开数据库 (每次shareDatabase系列操作时已经open,当调用close后若进行db操作需重新open或调用shareDatabase)
 */
- (void)open;

#pragma mark - 线程安全
/**
 将操作语句放入block中，保证多线程数据安全

 @param block 块
 */
- (void)md_inDatabase:(void (^)(void))block;
#pragma mark - 事务
/**
 事务: 将操作语句放入block中可执行回滚操作，保证数据库完整

 @param block 块
 */
- (void)md_inTransaction:(void(^)(BOOL *rollback))block;


@end


