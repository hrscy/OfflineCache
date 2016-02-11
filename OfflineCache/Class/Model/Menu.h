//
//  Menu.h
//  OfflineCache
//
//  Created by 杨蒙 on 16/2/10.
//  Copyright © 2016年 杨蒙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject

@property (nonatomic, copy) NSString *burden;

@property (nonatomic, strong) NSArray *albums;

@property (nonatomic, copy) NSString *imtro;

@property (nonatomic, copy) NSString *meunID;

@property (nonatomic, copy) NSString *ingredients;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSMutableArray *steps;

@property (nonatomic, copy) NSString *tags;

-(instancetype)initWithDict:(NSDictionary *)dict;

@end

@interface Steps : NSObject <NSCoding>

@property (nonatomic, copy) NSString *img;

@property (nonatomic, copy) NSString *step;

-(instancetype)initWithDict:(NSDictionary *)dict;

@end

