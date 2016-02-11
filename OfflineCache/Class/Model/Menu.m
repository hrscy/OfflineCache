//
//  Menu.m
//  OfflineCache
//
//  Created by 杨蒙 on 16/2/10.
//  Copyright © 2016年 杨蒙. All rights reserved.
//

#import "Menu.h"
#import "SQLiteManager.h"

@implementation Menu

-(instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.meunID = dict[@"id"];
        self.title = dict[@"title"];
        self.tags = dict[@"tags"];
        self.ingredients = dict[@"ingredients"];
        self.imtro = dict[@"imtro"];
        self.burden = dict[@"burden"];
        self.albums = dict[@"albums"];
        NSArray *stepsArray = dict[@"steps"];
        for (NSDictionary * dict in stepsArray) {
            Steps *steps = [[Steps alloc] initWithDict:dict];
            //缓存
            [[SQLiteManager sharedInstance] saveSteps:steps];
            [self.steps addObject:steps];
        }
    }
    return self;
}

-(NSMutableArray *)steps{
    if (_steps == nil) {
        _steps = [[NSMutableArray alloc] init];
    }
    return _steps;
}

@end

@implementation Steps

-(instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.img = dict[@"img"];
        self.step = dict[@"step"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.img forKey:@"img"];
    [encoder encodeObject:self.step forKey:@"step"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.img = [decoder decodeObjectForKey:@"img"];
        self.step = [decoder decodeObjectForKey:@"step"];
    }
    return self;
}

@end


