# OfflineCache

# iOS离线缓存

为了节省流量和更好的用户体验，目前很多应用都使用本地缓存机制，不需要每次打开app的时候都加载数据，或者重新向服务器请求数据，因此可以把每次浏览的数据保存到沙盒中，当下次打开软件的时候，首先从沙盒加载缓存的数据，或者当app未联网的时候，从沙盒中加载之前缓存的旧数据。

## 离线数据的方法选择

1. plist文件
2. Document路径
3. 数据库

由于保存的是大批量数据，且会不停的刷新新数据，因此应该选择数据库来存储。使用数据库可以快速地进行数据的读取操作。

## 1.设计思路

如下图，说明了离线缓存的流程：

![离线缓存](http://i12.tietuku.com/78bea772b0ea0296.png)

1. 当第一次打开app的时候，把从服务器获取到的数据保存到沙盒中；
2. 当下一次进入app的时候，首先从沙盒中找，如果沙盒中保存了之前的数据，则显示沙盒中的数据;
3. 如果没有网络，直接加载保存到沙盒中的数据。

## 2.实际应用

![示例](http://i12.tietuku.com/416248255ff2b873.png)

下面使用一个示例程序来介绍离线缓存。示例程序用到的框架有FMDB，SDWebImage，AFNetworking，数据是由聚合数据提供的开放API。

###JSON返回示例


```
{
    "resultcode": "200",
    "reason": "Success",
    "result": {
        "data": [
            {
                "id": "1001",
                "title": "糖醋小排",
                "tags": "浙菜;热菜;儿童;酸甜;快手菜",
                "imtro": "糖醋小排，我估计爱吃的人太多了，要想做好这道菜，关键就是调料汁的配置，老抽不能放的太多，那样颜色太重， 不好看，调料汁调好后，最好尝一下，每个人的口味都会不同的，可以适当微调一下哈！",
                "ingredients": "肋排,500g",
                "burden": "葱,适量;白芝麻,适量;盐,3g;生粉,45g;料酒,30ml;鸡蛋,1个;葱,1小段;姜,3片;老抽,7ml;醋,30ml;白糖,20g;番茄酱,15ml;生抽,15ml;生粉,7g;姜,适量",
                "albums": [
                    "http://img.juhe.cn/cookbook/t/1/1001_253951.jpg"
                ],
                "steps": [
                    {
                        "img": "http://img.juhe.cn/cookbook/s/10/1001_40ec58177e146191.jpg",
                        "step": "1.排骨剁小块，用清水反复清洗，去掉血水"
                    },
                    {
                        "img": "http://img.juhe.cn/cookbook/s/10/1001_034906d012e61fcc.jpg",
                        "step": "2.排骨放入容器中，放入腌料，搅拌均匀，腌制5分钟"
                    },
                    {
                        "img": "http://img.juhe.cn/cookbook/s/10/1001_b04cddaea2a1a604.jpg",
                        "step": "3.锅中放适量油，烧至5成热，倒入排骨，炸至冒青烟时捞出，关火，等油温降至五成热时，开火，再次放入排骨，中火炸至焦黄、熟透捞出"
                    },
                    {
                        "img": "http://img.juhe.cn/cookbook/s/10/1001_56b92264df500f01.jpg",
                        "step": "4.锅中留少许底油，放入葱花、姜片爆香"
                    },
                    {
                        "img": "http://img.juhe.cn/cookbook/s/10/1001_d78c57536a08dc4b.jpg",
                        "step": "5.放入适量炸好的排骨，倒入调料汁，煮至汤汁浓稠时，关火，撒入葱花、白芝麻点缀即可"
                    }
                ]
            }
        ],
        "totalNum": 1,
        "pn": 0,
        "rn": 1
    },
    "error_code": 0
}
```

### 在SQLiteManager.m中

单例:

```
// 单例
+(SQLiteManager *)sharedInstance {
    @synchronized(self) {
        if (shareObj == nil) {
            shareObj = [[self alloc] init];
        }
    }
    return shareObj;
}
```

数据库初始化：

```
// 初始化数据库
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
```

从数据库获取数据：

```
//从数据库获取数据
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
```
保存数据到数据库:

```
// 保存数据到数据库
-(void)saveSteps:(Steps *)step {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:step];
    [self.database executeUpdateWithFormat:@"INSERT INTO t_step(step) VALUES (%@);", data];
}
```

### MenuTableViewController.m中

获取服务器数据:


```
//获取服务器数据
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
```

## 3.清除图片

如下图：

![清除图片](http://i12.tietuku.com/a3d5c553fa968402.png)

SDImageCache中提供了获取当前缓存大小和清除缓存的的方法。

### MenuTableViewController.m中

获取当前缓存大小:

```
//字节大小
int byteSize = (int)[SDImageCache sharedImageCache].getSize;
//M大小
CGFloat cacheSize = byteSize / 1000.0 / 1000.0;
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清理缓存" message:[NSString stringWithFormat:@"缓存大小%.1fM",cacheSize] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
[alert show];
```

清除缓存:

```
//清除缓存
[[SDImageCache sharedImageCache] clearDisk];
```

## 4.文件操作
使用SDImageCache可以清除图片的缓存，但是有些缓存并不是图片缓存，例如用户临时看的视频文件或mp3文件，如果想要清除这些文件，就要使用文件操作的方法，遍历沙盒中的Library/Cache文件夹，自己算出缓存文件夹的大小，把所有缓存文件清除。

	注：文件夹是没有大小的，只有文件有大小属性。

```
//计算当前文件夹的大小
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
```

## [示例程序](https://github.com/hrscy/OfflineCache)






