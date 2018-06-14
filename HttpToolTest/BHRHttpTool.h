//
//  FQHttpTool.h
//  ShiYiKe
//
//  Created by xiejiamac03 on 16/5/25.
//  Copyright © 2016年 xiejia. All rights reserved.
//


/**使用案例
 
 FQURLSessionTask *task;
 
 //参数
 NSMutableDictionary *params = [NSMutableDictionary dictionary];
 params[@"a"] = @"category";
 params[@"c"] = @"subscribe";
 
 //联网
 task = [FQHttpTool getWithUrl:@"http://api.budejie.com/api/api_open.php" params:params success:^(id response) {
    FQLog(@"=====%@",response);//成功
 } fail:^(NSError *error) {
    FQLog(@"error : %@",error);//失败
 } showHUD:YES];
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    StatusUnKnown       = -1,//未知网络
    StatusNotReachable  = 0,//没有网络
    StatusReachableWWAN = 1,//手机自带网络
    StatusReachableWiFI = 2 //wifi
} NetworkStatus;


//定义block
typedef void (^ FQResponseSuccess) (id response);
typedef void (^ FQResponseFail)(NSError *error);

typedef void (^ FQUploadProgress)(int64_t bytesProgress,int64_t totalBtytesProgress);
typedef void (^ FQDownloadProgress)(int64_t bytesProgress,int64_t totalByteProgress);

/**
 *  执行取消，暂停，继续等任务.
 *  - (void)cancel， 取消任务
 *  - (void)suspend，暂停任务
 *  - (void)resume， 继续任务
 */
typedef NSURLSessionTask FQURLSessionTask;



@interface BHRHttpTool : NSObject

//FQSingletonH
/**
 *  获取网络
 */
@property (nonatomic,assign)NetworkStatus networkStats;


/**
 *  get请求方法,block回调
 *
 *  @param url     请求连接，根路径
 *  @param params  参数
 *  @param tokenValue  token
 *  @param success 请求成功返回数据
 *  @param fail    请求失败
 *  @param showHUD 是否显示HUD
 */
+(FQURLSessionTask *)getWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(FQResponseSuccess)success
                            fail:(FQResponseFail)fail
                         showHUD:(BOOL)showHUD;

+(FQURLSessionTask *)postWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                       headParams:(NSDictionary*)headParams
                          success:(FQResponseSuccess)success
                             fail:(FQResponseFail)fail
                          showHUD:(BOOL)showHUD;
/**
 *  post请求方法,block回调
 *
 *  @param url     请求连接，根路径
 *  @param params  参数
 *  @param tokenValue  token
 *  @param success 请求成功返回数据
 *  @param fail    请求失败
 *  @param showHUD 是否显示HUD
 */
+(FQURLSessionTask *)postWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                          success:(FQResponseSuccess)success
                             fail:(FQResponseFail)fail
                          showHUD:(BOOL)showHUD;
+(FQURLSessionTask *)postNoEncodeWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(FQResponseSuccess)success
                            fail:(FQResponseFail)fail
                         showHUD:(BOOL)showHUD;

+(FQURLSessionTask *)deleteWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                            headParams:(NSDictionary*)headParams
                          success:(FQResponseSuccess)success
                             fail:(FQResponseFail)fail
                          showHUD:(BOOL)showHUD;


/**
 *  上传图片方法
 *
 *  @param image      上传的图片
 *  @param url        请求连接，根路径
 *  @param filename   图片的名称(如果不传则以当时间命名)
 *  @param name       上传图片时填写的图片对应的参数
 *  @param params     参数
 *  @param progress   上传进度
 *  @param success    请求成功返回数据
 *  @param fail       请求失败
 *  @param showHUD    是否显示HUD
 */
+(FQURLSessionTask *)uploadWithImage:(NSData *)imageData
                                  url:(NSString *)url
                             filename:(NSString *)filename
                                 name:(NSString *)name
                               params:(NSDictionary *)params
                           headParams:(NSDictionary *)headParams
                             progress:(FQUploadProgress)progress
                              success:(FQResponseSuccess)success
                                 fail:(FQResponseFail)fail
                              showHUD:(BOOL)showHUD;

/**
 *  下载文件方法
 *
 *  @param url           下载地址
 *  @param saveToPath    文件保存的路径,如果不传则保存到Documents目录下，以文件本来的名字命名
 *  @param progressBlock 下载进度回调
 *  @param success       下载完成
 *  @param fail          失败
 *  @param showHUD       是否显示HUD
 *  @return 返回请求任务对象，便于操作
 */
+ (FQURLSessionTask *)downloadWithUrl:(NSString *)url
                           saveToPath:(NSString *)saveToPath
                             progress:(FQDownloadProgress )progressBlock
                              success:(FQResponseSuccess )success
                              failure:(FQResponseFail )fail
                              showHUD:(BOOL)showHUD;

//上传文件
+(FQURLSessionTask *)uploadWithData:(NSData *)data
                                 url:(NSString *)url
                            filename:(NSString *)filename
                                name:(NSString *)name
                              params:(NSDictionary *)params
                          headParams:(NSDictionary *)headParams
                            progress:(FQUploadProgress)progress
                             success:(FQResponseSuccess)success
                                fail:(FQResponseFail)fail
                             showHUD:(BOOL)showHUD;

//+ (void)startMonitoring;
@end
