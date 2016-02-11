//
//  MenuTableViewController.m
//  OfflineCache
//
//  Created by 杨蒙 on 16/2/10.
//  Copyright © 2016年 杨蒙. All rights reserved.
//

#import "MenuTableViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "SQLiteManager.h"
#import "Menu.h"
#import "MenuCell.h"

@interface MenuTableViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *stepsArray;

@end

@implementation MenuTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详细步骤";
    //右上角清理缓存按钮
    [self setupRightBarButonItem];
    
    self.tableView.rowHeight = 120;
    self.tableView.tableFooterView = [UIView new];
    
    //获取服务器数据
    [self getData];
}

#pragma mark 右上角清理缓存按钮
-(void)setupRightBarButonItem {
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"清理缓存" style:UIBarButtonItemStyleDone target:self action:@selector(barButtonItemClick)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

#pragma amrk 点击清理缓存按钮
-(void)barButtonItemClick {
    //字节大小
    int byteSize = (int)[SDImageCache sharedImageCache].getSize;
    //M大小
    CGFloat cacheSize = byteSize / 1000.0 / 1000.0;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清理缓存" message:[NSString stringWithFormat:@"缓存大小%.1fM",cacheSize] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark -UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //清除缓存
        [[SDImageCache sharedImageCache] clearDisk];
    }
}

#pragma amrk 获取服务器数据
-(void)getData {
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] init];
    
    NSString *url = @"http://apis.juhe.cn/cook/queryid";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = self.menuID;
    params[@"key"] = self.appKey;
    params[@"dtype"] = self.dtype;
    //从数据库获取数据
    NSArray *steps = [[SQLiteManager sharedInstance] stepsFromSqlite];
    if (steps.count) {
        self.stepsArray = [NSMutableArray arrayWithArray:steps];
    } else {
        //get请求，从服务器获取数据
        [session GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = responseObject[@"result"];
            NSArray *data = result[@"data"];
            for (NSDictionary *dict in data) {
                Menu *menu = [[Menu alloc] initWithDict:dict];
                self.stepsArray = menu.steps;
            }
            [self.tableView reloadData];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error=%@",error);
        }];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stepsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Steps *step = self.stepsArray[indexPath.row];
    static NSString *ID = @"cell";
    BOOL nibReigister = NO;
    if (!nibReigister) {
        UINib *nib = [UINib nibWithNibName:@"MenuCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:ID];
        nibReigister = YES;
    }
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:step.img] placeholderImage:nil];
    cell.stepLabel.text = step.step;
    return cell;
}

-(NSMutableArray *)stepsArray{
    if (_stepsArray == nil) {
        _stepsArray = [[NSMutableArray alloc] init];
    }
    return _stepsArray;
}

@end
