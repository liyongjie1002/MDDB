//
//  MDDB.m
//
//  Created by muheda on 18/8/18.
//

#import "MDDB.h"
#import "FMDB.h"
#import <objc/runtime.h>


// 数据库中常见的几种类型
#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //int long integer ...
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //data

@interface MDDB ()

@property (nonatomic, strong)NSString *dbPath;
@property (nonatomic, strong)FMDatabaseQueue *dbQueue;
@property (nonatomic, strong)FMDatabase *db;

@end

@implementation MDDB

- (FMDatabaseQueue *)dbQueue
{
    if (!_dbQueue) {
        FMDatabaseQueue *fmdb = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
        self.dbQueue = fmdb;
        [_db close];
        self.db = [fmdb valueForKey:@"_db"];
    }
    return _dbQueue;
}
#pragma mark - 单例创建数据库
static MDDB *mddb = nil;

+ (instancetype)shareDatabase:(NSString *)dbName
{
    return [MDDB shareDatabase:dbName path:nil];
}

+ (instancetype)shareDatabase:(NSString *)dbName path:(NSString *)dbPath
{
    if (!mddb) {
        
        NSString *path;
        if (!dbName) {
            dbName = @"MD.db";
        }
        if (!dbPath) {
            path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dbName];
        } else {
            path = [dbPath stringByAppendingPathComponent:dbName];
        }
        NSLog(@"数据库路径%@",path);
        FMDatabase *fmdb = [FMDatabase databaseWithPath:path];
        if ([fmdb open]) {
            mddb = MDDB.new;
            mddb.db = fmdb;
            mddb.dbPath = path;
        }
    }
    if (![mddb.db open]) {
        NSLog(@"数据库打不开");
        return nil;
    };
    return mddb;
}

#pragma mark - 创建表
- (BOOL)md_createTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr
{
    
    NSDictionary *dic;
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    } else {
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        dic = [self modelToDictionary:CLS excludePropertyName:nameArr];
    }
    
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@ (mid  INTEGER PRIMARY KEY,", tableName];
    
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        if ((nameArr && [nameArr containsObject:key]) || [key isEqualToString:@"mid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    BOOL creatFlag;
    creatFlag = [_db executeUpdate:fieldStr];
    
    return creatFlag;
}

- (NSString *)createTable:(NSString *)tableName dictionary:(NSDictionary *)dic excludeName:(NSArray *)nameArr
{
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@ (mid  INTEGER PRIMARY KEY,", tableName];
    
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        if ((nameArr && [nameArr containsObject:key]) || [key isEqualToString:@"mid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    return fieldStr;
}

- (NSString *)createTable:(NSString *)tableName model:(Class)cls excludeName:(NSArray *)nameArr
{
    NSMutableString *fieldStr = [[NSMutableString alloc] initWithFormat:@"CREATE TABLE %@ (mid INTEGER PRIMARY KEY,", tableName];
    
    NSDictionary *dic = [self modelToDictionary:cls excludePropertyName:nameArr];
    int keyCount = 0;
    for (NSString *key in dic) {
        
        keyCount++;
        
        if ([key isEqualToString:@"mid"]) {
            continue;
        }
        if (keyCount == dic.count) {
            [fieldStr appendFormat:@" %@ %@)", key, dic[key]];
            break;
        }
        
        [fieldStr appendFormat:@" %@ %@,", key, dic[key]];
    }
    
    return fieldStr;
}

#pragma mark - *************** runtime
- (NSDictionary *)modelToDictionary:(Class)cls excludePropertyName:(NSArray *)nameArr
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if ([nameArr containsObject:name]) continue;
        
        NSString *type = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
        
        id value = [self propertTypeConvert:type];
        if (value) {
            [mDic setObject:value forKey:name];
        }
        
    }
    free(properties);
    
    return mDic;
}

// 获取model的key和value
- (NSDictionary *)getModelPropertyKeyValue:(id)model tableName:(NSString *)tableName clomnArr:(NSArray *)clomnArr
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if (![clomnArr containsObject:name]) {
            continue;
        }
        
        id value = [model valueForKey:name];
        if (value) {
            [mDic setObject:value forKey:name];
        }else{
            [mDic setObject:@"" forKey:name];
        }
    }
    free(properties);
    
    return mDic;
}

- (NSString *)propertTypeConvert:(NSString *)typeStr
{
    NSString *resultStr = nil;
    if ([typeStr hasPrefix:@"T@\"NSString\""]) {
        resultStr = SQL_TEXT;
    } else if ([typeStr hasPrefix:@"T@\"NSData\""]) {
        resultStr = SQL_BLOB;
    } else if ([typeStr hasPrefix:@"Ti"]||[typeStr hasPrefix:@"TI"]||[typeStr hasPrefix:@"Ts"]||[typeStr hasPrefix:@"TS"]||[typeStr hasPrefix:@"T@\"NSNumber\""]||[typeStr hasPrefix:@"TB"]||[typeStr hasPrefix:@"Tq"]||[typeStr hasPrefix:@"TQ"]) {
        resultStr = SQL_INTEGER;
    } else if ([typeStr hasPrefix:@"Tf"] || [typeStr hasPrefix:@"Td"]){
        resultStr= SQL_REAL;
    }
    
    return resultStr;
}

// 得到表里的字段名称
- (NSArray *)getColumnArr:(NSString *)tableName db:(FMDatabase *)db
{    
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    
    FMResultSet *resultSet = [db getTableSchema:tableName];
    
    while ([resultSet next]) {
        [mArr addObject:[resultSet stringForColumn:@"name"]];
    }
    
    return mArr;
}

#pragma mark - *************** 增删改查
- (BOOL)md_insertTable:(NSString *)tableName dicOrModel:(id)parameters
{
    NSArray *columnArr = [self getColumnArr:tableName db:_db];
    return [self insertTable:tableName dicOrModel:parameters columnArr:columnArr];
}
- (BOOL)insertTable:(NSString *)tableName dicOrModel:(id)parameters columnArr:(NSArray *)columnArr
{
    BOOL flag;
    NSDictionary *dic;
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else {
        dic = [self getModelPropertyKeyValue:parameters tableName:tableName clomnArr:columnArr];
    }
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@ (", tableName];
    NSMutableString *tempStr = [NSMutableString stringWithCapacity:0];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *key in dic) {
        
        if (![columnArr containsObject:key] || [key isEqualToString:@"mid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@,", key];
        [tempStr appendString:@"?,"];
        
        [argumentsArr addObject:dic[key]];
    }
    
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (tempStr.length)
        [tempStr deleteCharactersInRange:NSMakeRange(tempStr.length-1, 1)];
    
    [finalStr appendFormat:@") values (%@)", tempStr];
    
    flag = [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    return flag;
}
#pragma mark 删除表中数据
- (BOOL)md_deleteTable:(NSString *)tableName whereFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    BOOL flag;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"delete from %@  %@", tableName,where];
    flag = [_db executeUpdate:finalStr];
    
    return flag;
}
#pragma mark 更新表中数据
- (BOOL)md_updateTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    BOOL flag;
    NSDictionary *dic;
    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
    }else {
        dic = [self getModelPropertyKeyValue:parameters tableName:tableName clomnArr:clomnArr];
    }
    
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"update %@ set ", tableName];
    NSMutableArray *argumentsArr = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *key in dic) {
        
        if (![clomnArr containsObject:key] || [key isEqualToString:@"mid"]) {
            continue;
        }
        [finalStr appendFormat:@"%@ = %@,", key, @"?"];
        [argumentsArr addObject:dic[key]];
    }
    
    [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length-1, 1)];
    if (where.length) [finalStr appendFormat:@" %@", where];
    
    
    flag =  [_db executeUpdate:finalStr withArgumentsInArray:argumentsArr];
    
    return flag;
}
#pragma mark 查询表中数据
- (NSArray *)md_queryTable:(NSString *)tableName dicOrModel:(id)parameters whereFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
    va_end(args);
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *dic;
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"select * from %@ %@", tableName, where?where:@""];
    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    
    FMResultSet *set = [_db executeQuery:finalStr];
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
        
        while ([set next]) {
            
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:0];
            for (NSString *key in dic) {
                
                if ([dic[key] isEqualToString:SQL_TEXT]) {
                    id value = [set stringForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                } else if ([dic[key] isEqualToString:SQL_INTEGER]) {
                    [resultDic setObject:@([set longLongIntForColumn:key]) forKey:key];
                } else if ([dic[key] isEqualToString:SQL_REAL]) {
                    [resultDic setObject:[NSNumber numberWithDouble:[set doubleForColumn:key]] forKey:key];
                } else if ([dic[key] isEqualToString:SQL_BLOB]) {
                    id value = [set dataForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                }
                
            }
            
            if (resultDic) [resultMArr addObject:resultDic];
        }
        
    }else {
        
        Class CLS;
        if ([parameters isKindOfClass:[NSString class]]) {
            if (!NSClassFromString(parameters)) {
                CLS = nil;
            } else {
                CLS = NSClassFromString(parameters);
            }
        } else if ([parameters isKindOfClass:[NSObject class]]) {
            CLS = [parameters class];
        } else {
            CLS = parameters;
        }
        
        if (CLS) {
            NSDictionary *propertyType = [self modelToDictionary:CLS excludePropertyName:nil];
            
            while ([set next]) {
                
                id model = CLS.new;
                for (NSString *name in clomnArr) {
                    if ([propertyType[name] isEqualToString:SQL_TEXT]) {
                        id value = [set stringForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_INTEGER]) {
                        [model setValue:@([set longLongIntForColumn:name]) forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_REAL]) {
                        [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:name]] forKey:name];
                    } else if ([propertyType[name] isEqualToString:SQL_BLOB]) {
                        id value = [set dataForColumn:name];
                        if (value)
                            [model setValue:value forKey:name];
                    }
                }
                
                [resultMArr addObject:model];
            }
        }
        
    }
    
    return resultMArr;
}
-(NSArray *)md_queryMutilTable:(NSArray *)tableNames dic:(id)parameters whereFormat:(NSString *)format, ...{
//    va_list args;
//    va_start(args, format);
//    NSString *where = format?[[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:args]:format;
//    va_end(args);
    NSMutableArray *resultMArr = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *dic = parameters;
    
    NSMutableString *columns = [NSMutableString string];
    NSArray *keys = dic.allKeys;
    NSInteger count = keys.count;
    for (int i=0; i<count; i++) {
        if (i == 0) {
            [columns appendFormat:@"%@", [NSString stringWithFormat:@"%@",keys[i]]];
        }else{
            [columns appendFormat:@"%@", [NSString stringWithFormat:@",%@",keys[i]]];
        }
    }
    NSMutableString *finalStr = [[NSMutableString alloc] initWithFormat:@"select %@ from %@ left join %@ on %@",columns, tableNames.firstObject,tableNames.lastObject, format?format:@""];
//    NSArray *clomnArr = [self getColumnArr:tableName db:_db];
    
    FMResultSet *set = [_db executeQuery:finalStr];
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        dic = parameters;
        
        while ([set next]) {
            
            NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:0];
            for (NSString *key in dic) {
                
                if ([dic[key] isEqualToString:SQL_TEXT]) {
                    id value = [set stringForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                } else if ([dic[key] isEqualToString:SQL_INTEGER]) {
                    [resultDic setObject:@([set longLongIntForColumn:key]) forKey:key];
                } else if ([dic[key] isEqualToString:SQL_REAL]) {
                    [resultDic setObject:[NSNumber numberWithDouble:[set doubleForColumn:key]] forKey:key];
                } else if ([dic[key] isEqualToString:SQL_BLOB]) {
                    id value = [set dataForColumn:key];
                    if (value)
                        [resultDic setObject:value forKey:key];
                }
            }
            if (resultDic) [resultMArr addObject:resultDic];
        }
        
    }
//    else {
//
//        Class CLS;
//        if ([parameters isKindOfClass:[NSString class]]) {
//            if (!NSClassFromString(parameters)) {
//                CLS = nil;
//            } else {
//                CLS = NSClassFromString(parameters);
//            }
//        } else if ([parameters isKindOfClass:[NSObject class]]) {
//            CLS = [parameters class];
//        } else {
//            CLS = parameters;
//        }
//
//        if (CLS) {
//            NSDictionary *propertyType = [self modelToDictionary:CLS excludePropertyName:nil];
//
//            while ([set next]) {
//
//                id model = CLS.new;
//                for (NSString *name in clomnArr) {
//                    if ([propertyType[name] isEqualToString:SQL_TEXT]) {
//                        id value = [set stringForColumn:name];
//                        if (value)
//                            [model setValue:value forKey:name];
//                    } else if ([propertyType[name] isEqualToString:SQL_INTEGER]) {
//                        [model setValue:@([set longLongIntForColumn:name]) forKey:name];
//                    } else if ([propertyType[name] isEqualToString:SQL_REAL]) {
//                        [model setValue:[NSNumber numberWithDouble:[set doubleForColumn:name]] forKey:name];
//                    } else if ([propertyType[name] isEqualToString:SQL_BLOB]) {
//                        id value = [set dataForColumn:name];
//                        if (value)
//                            [model setValue:value forKey:name];
//                    }
//                }
//                [resultMArr addObject:model];
//            }
//        }
//    }
    return resultMArr;
}
#pragma mark 插入一组数据
- (void)md_insertTable:(NSString *)tableName dicOrModelArray:(NSArray *)dicOrModelArray success:(void (^)(int))block {
    
    __block BOOL result = YES;
    NSArray *columnArr = [self getColumnArr:tableName db:_db];

    [self md_inTransaction:^(BOOL *rollback) {
        for (id parameters in dicOrModelArray) {
            
            BOOL flag = [self insertTable:tableName dicOrModel:parameters columnArr:columnArr];
            if (!flag) {
                *rollback = YES; //只要有一次不成功,则进行回滚操作
                result = !*rollback;
                return;
            }
        }
    }];
    block(result);
}
#pragma mark 删除表
- (BOOL)md_deleteTable:(NSString *)tableName
{
    
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    
    [_db close];//此处在删除表之前，可能出现表被锁的情况，关闭重新打开数据库解决
    
    if (![_db open]) {
        [_db open];
    }
    
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    return YES;
}
#pragma mark 删除表中所有数据
- (BOOL)md_deleteAllDataFromTable:(NSString *)tableName
{
    
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![_db executeUpdate:sqlstr])
    {
        return NO;
    }
    
    return YES;
}
#pragma mark 是否存在表
- (BOOL)md_isExistTable:(NSString *)tableName
{
    
    FMResultSet *set = [_db executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", tableName];
    while ([set next])
    {
        NSInteger count = [set intForColumn:@"count"];
        if (count == 0) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}
#pragma mark 得到表里的字段名称
- (NSArray *)md_columnNameArray:(NSString *)tableName
{
    return [self getColumnArr:tableName db:_db];
}
#pragma mark 行数
- (int)md_numberOfTable:(NSString *)tableName
{
    
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *set = [_db executeQuery:sqlstr];
    while ([set next])
    {
        return [set intForColumn:@"count"];
    }
    return 0;
}
#pragma mark 数据库开关
- (void)close
{
    [_db close];
}

- (void)open
{
    [_db open];
}
#pragma mark 修改表结构
//增加字段
- (BOOL)md_addCoumnOfTable:(NSString *)tableName dicOrModel:(id)parameters excludeName:(NSArray *)nameArr
{
    __block BOOL flag;
    __weak typeof(self) weakSelf =self;
    [self md_inTransaction:^(BOOL *rollback) {
        if ([parameters isKindOfClass:[NSDictionary class]]) {
            for (NSString *key in parameters) {
                if ([nameArr containsObject:key]) {
                    continue;
                }
                flag = [weakSelf.db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, key, parameters[key]]];
                if (!flag) {
                    *rollback = YES;
                    return;
                }
            }
            
        } else {
            Class CLS;
            if ([parameters isKindOfClass:[NSString class]]) {
                if (!NSClassFromString(parameters)) {
                    CLS = nil;
                } else {
                    CLS = NSClassFromString(parameters);
                }
            } else if ([parameters isKindOfClass:[NSObject class]]) {
                CLS = [parameters class];
            } else {
                CLS = parameters;
            }
            NSDictionary *modelDic = [self modelToDictionary:CLS excludePropertyName:nameArr];
            NSArray *columnArr = [self getColumnArr:tableName db:weakSelf.db];
            for (NSString *key in modelDic) {
                if (![columnArr containsObject:key] && ![nameArr containsObject:key]) {
                    flag = [weakSelf.db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, key, modelDic[key]]];
                    if (!flag) {
                        *rollback = YES;
                        return;
                    }
                }
            }
        }
    }];
    
    return flag;
}
#pragma mark - =============================    数据库升级    ==============================
#pragma mark 修改表名
-(BOOL)md_alterTableName:(NSString *)tableName withTableStr:(NSString *)tableStr{
    BOOL flag = [_db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@",tableName,tableStr]];
    return flag;
}
#pragma mark 删除字段
-(BOOL)md_deleteTable:(NSString *)tableName dicOrModel:(id)parameters withStr:(NSArray *)arr{
    NSString *tempTableName = [NSString stringWithFormat:@"temp_%@",tableName];
    if (![self md_isExistTable:tableName]) {
        return NO;
    }
    //更改为临时表
    [self md_alterTableName:tableName withTableStr:tempTableName];
    //创建新表
    [self md_createTable:tableName dicOrModel:parameters excludeName:arr];
    //导入数据
    NSArray *tempArr = [self md_queryTable:tempTableName dicOrModel:parameters whereFormat:@""];
    [self md_insertTable:tableName dicOrModelArray:tempArr success:^(int success) {
        
    }];
    //自增长时。更新sqlite_sequence
    //删除临时表
    return [self md_deleteTable:tempTableName];
}
#pragma mark 修改字段名
-(void)md_alterColumnOfTable:(NSString *)tableName oldColumn:(NSString *)oldColumn newColumn:(NSString *)newColumn newColumnType:(NSString *)newColumnType dicOrModel:(id)dicOrModel excludeArr:(NSArray *)excludeArr{
    if (![_db columnExists:oldColumn inTableWithName:tableName])
        return;
    
    NSLog(@"%@表中存在%@字段,修改%@字段名称为%@", tableName, oldColumn, oldColumn, newColumn);
    // 1.添加新字段
    if (![_db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, newColumn, newColumnType]]) {
        NSLog(@"%@修改字段：添加新字段%@失败", tableName, newColumn);
    }
    // 2.将旧字段赋值给新字段
    if (![_db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET %@ = %@", tableName, newColumn, oldColumn]]) {
        NSLog(@"%@修改字段：%@赋值%@字段失败", tableName, oldColumn, newColumn);
        return;
    }
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSString *str in excludeArr) {
        [tempArr addObject:str];
    }
    [tempArr addObject:oldColumn];
    // 3.删除旧字段
    [self md_deleteTable:tableName dicOrModel:dicOrModel withStr:tempArr];
    
}

#pragma mark - =============================   线程安全操作    ===============================
- (void)md_inDatabase:(void(^)(void))block
{
    
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        block();
    }];
}
- (void)md_inTransaction:(void(^)(BOOL *rollback))block
{
    
    [[self dbQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        block(rollback);
    }];
    
}


@end

