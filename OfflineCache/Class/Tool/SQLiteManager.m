//
//  SQLiteManager.m
//  OfflineCache
//
//  Created by 杨蒙 on 16/2/10.
//  Copyright © 2016年 杨蒙. All rights reserved.
//

#import "SQLiteManager.h"
#import "FMDB.h"
#import "Menu.h"

@interface SQLiteManager ()

@property (nonatomic, strong) FMDatabase *database;

@end
//静态实例，并初始化
static SQLiteManager *shareObj = nil;

@implementation SQLiteManager

#pragma mark 单例
+(SQLiteManager *)sharedInstance {
    @synchronized(self) {
        if (shareObj == nil) {
            shareObj = [[self alloc] init];
        }
    }
    return shareObj;
}

#pragma mark 初始化数据库
-(instancetype)init {
    if (self = [super init]) {
        //文件路径
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"step.sqlite"];
        //初始化数据库
        self.database = [FMDatabase databaseWithPath:path];
        //打开数据库
        [self.database open];
        
        if ([self.database open]) {
            //将step采用blob类型来存储
            NSString *create = @"CREATE TABLE IF NOT EXISTS t_step(id integer PRIMARY KEY, step blob NOT NULL);";
            [self.database executeUpdate:create];
        }
    }
    return self;
}

#pragma mark 从数据库获取数据
-(NSArray *)stepsFromSqlite {
    NSString *sql = @"SELECT * FROM t_step";
    FMResultSet *set = [self.database executeQuery:sql];
    NSMutableArray *steps = [NSMutableArray array];
    while (set.next) {
        NSData *data = [set objectForColumnName:@"step"];
        Steps *step = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [steps addObject:step];
    }
    return steps;
}

#pragma mark 保存数据到数据库
-(void)saveSteps:(Steps *)step {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:step];
    [self.database executeUpdateWithFormat:@"INSERT INTO t_step(step) VALUES (%@);", data];
}

@end
