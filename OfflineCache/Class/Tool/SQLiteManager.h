//
//  SQLiteManager.h
//  OfflineCache
//
//  Created by 杨蒙 on 16/2/10.
//  Copyright © 2016年 杨蒙. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Steps;

@interface SQLiteManager : NSObject

+(SQLiteManager *)sharedInstance;

-(NSArray *)stepsFromSqlite;

-(void)saveSteps:(Steps *)steps;

@end
