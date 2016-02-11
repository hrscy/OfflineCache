//
//  ViewController.m
//  OfflineCache
//
//  Created by 杨蒙 on 16/2/10.
//  Copyright © 2016年 杨蒙. All rights reserved.
//

#import "ViewController.h"
#import "MenuTableViewController.h"

@interface ViewController ()
//菜谱ID
@property (weak, nonatomic) IBOutlet UILabel *menuID;
//appKey
@property (weak, nonatomic) IBOutlet UILabel *appKey;
//返回数据的格式
@property (weak, nonatomic) IBOutlet UILabel *dtype;

- (IBAction)buttonAction:(UIButton *)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"菜谱";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonAction:(UIButton *)sender {
    MenuTableViewController *menuVC = [[MenuTableViewController alloc] init];
    menuVC.menuID = self.menuID.text;
    menuVC.appKey = self.appKey.text;
    menuVC.dtype = self.dtype.text;
    [self.navigationController pushViewController:menuVC animated:YES];
    
}
@end
