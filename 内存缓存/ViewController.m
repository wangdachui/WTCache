//
//  ViewController.m
//  内存缓存
//
//  Created by charles on 14-11-19.
//  Copyright (c) 2014年 ZZ. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"

@interface ViewController ()<SDWebImageManagerDelegate>
@property(nonatomic,strong)NSURLConnection* connection;
@property (weak, nonatomic) IBOutlet UIImageView*imageView;
@property(nonatomic,strong)NSString* UserPath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}
//保存文件到沙箱
- (NSString *)saveFileToDocuments:(NSString *)url
{
    NSString *resultFilePath = @"";
    
        
        NSString *destFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:url]; // 加上url，组合成本地文件PATH
        NSString *destFolderPath = [destFilePath stringByDeletingLastPathComponent];
        
        // 判断路径文件夹是否存在不存在则创建
        if (! [[NSFileManager defaultManager] fileExistsAtPath:destFolderPath]) {
            NSLog(@"文件夹不存在，新建文件夹");
            [[NSFileManager defaultManager] createDirectoryAtPath:destFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // 判断该文件是否已经下载过
        if ([[NSFileManager defaultManager] fileExistsAtPath:destFilePath]) {
            NSLog(@"文件已下载\n");
            resultFilePath = destFilePath;
        } else {
            
            NSLog(@"没有缓存，请求数据\n");
            NSData *userInfoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            
            if ([userInfoData writeToFile:destFilePath atomically:YES]) {
                resultFilePath = destFilePath;
            }
        }
    NSData *userInfoData=[[NSFileManager defaultManager] contentsAtPath:resultFilePath];
    NSString* str = [[NSString alloc]initWithData:userInfoData encoding:NSUTF8StringEncoding];
    
    NSLog(@"=========================================================\n");
    NSLog(@"user:%@",str);
    NSLog(@"=========================================================\n");
    
  
    return resultFilePath;
}
//网络请求的内存缓存方法
-(void)getByURL:(NSString *)path andCallBack:(CallBack)callback{
    
    NSString*  pathStr = [path  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:pathStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadRevalidatingCacheData];
    NSCachedURLResponse* response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
    //判断是否有缓存
    if (response != nil) {
        NSLog(@"有缓存");
        [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
    }else{
        
        NSLog(@"没有缓存");
    }
    
    //创建NSURLConnection
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    callback(data);
    
}
//用户信息缓存用文件保存在沙箱
- (IBAction)userCache:(UIButton *)sender {

    self.UserPath = [self saveFileToDocuments:@"http://www.weather.com.cn/data/sk/101020100.html"];
}
//图片缓存用第三方SDWebImage
- (IBAction)imageCache:(UIButton *)sender {
    
    NSURL* url = [NSURL URLWithString:@"http://img2.itsogo.net/Upfile2/2014/11/11491014839118.jpg"];
    [self.imageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (cacheType==SDImageCacheTypeNone) {
            
            NSLog(@"没有缓存，从网络下载");
            
        }else if (cacheType==SDImageCacheTypeDisk){
            
            NSLog(@"有缓存，从磁盘读取");
            
        }else{
            
            NSLog(@"有缓存，从内存读取");
        }

    }];

    [self.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"1"] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (cacheType==SDImageCacheTypeNone) {
            
            NSLog(@"没有缓存，从网络下载");
            
        }else if (cacheType==SDImageCacheTypeDisk){
            
            NSLog(@"有缓存，从磁盘读取");
            
        }else{
            
            NSLog(@"有缓存，从内存读取");
        }

    }];
    
   
}

//网络缓存响应方法
- (IBAction)senderButton:(id)sender {

    //天气Api接口
    NSString* path = @"http://www.weather.com.cn/data/sk/101110101.html";
    [self getByURL:path andCallBack:^(id obj) {
   
    NSString *str = [[NSString alloc]initWithData:obj encoding:NSUTF8StringEncoding];
    NSLog(@"=========================================================\n");
    NSLog(@"post缓存测试：%@",str);
    NSLog(@"=========================================================\n");
    }];

    
    
}
- (IBAction)clearPost:(UIButton *)sender {
    
    NSLog(@"清空post缓存");
     [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
- (IBAction)clearuser:(UIButton *)sender {
    
    NSLog(@"清空user缓存");
    if (self.UserPath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.UserPath error:nil];
    }
    
}

- (IBAction)clearImage:(UIButton *)sender {
    
    NSLog(@"清空iamge磁盘缓存和内存缓存");
    SDImageCache* imageCache = [SDImageCache sharedImageCache];
    //[imageCache clearDisk];
    [imageCache clearMemory];
    
}
- (IBAction)clearCache:(UIButton *)sender {
    
    NSLog(@"清空post图片磁盘缓存");
    [[SDImageCache sharedImageCache] clearDisk];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
