//
//  NSString+Extension.m
//  OfflineCache
//
//  Created by 杨蒙 on 16/2/11.
//  Copyright © 2016年 杨蒙. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

-(NSInteger)cachesFileSize {
    //文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    //判断是否为文件
    BOOL dir = NO;
    BOOL exists = [mgr fileExistsAtPath:self isDirectory:&dir];
    if (!exists) return 0;//说明文件或文件夹不存在
    if (dir) { //self是一个文件夹
        //遍历caches里面的内容 -- 直接和间接内容
        NSArray *subpaths = [mgr subpathsAtPath:self];
        NSInteger totalBytes = 0;
        //如果self是一个文件夹，则遍历该文件夹下的文件
        for (NSString *subpath in subpaths) {
            //获得全路径
            NSString *fullpath = [self stringByAppendingPathComponent:subpath];
            BOOL directory = NO;
            [mgr fileExistsAtPath:fullpath isDirectory:&directory];
            if (!directory) { // self不是文件夹，计算文件的大小
                totalBytes += [[mgr attributesOfItemAtPath:fullpath error:nil][NSFileSize] integerValue];
            }
        }
        return totalBytes;
    } else { //self是一个文件
        return [[mgr attributesOfItemAtPath:self error:nil][NSFileSize] integerValue];
    }
}

@end
