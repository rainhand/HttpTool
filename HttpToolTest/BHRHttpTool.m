//
//  FQHttpTool.m
//  ShiYiKe
//
//  Created by xiejiamac03 on 16/5/25.
//  Copyright © 2016年 xiejia. All rights reserved.
//

#import "BHRHttpTool.h"
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#else
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

#import "SecurityUtil.h"
#import "NSData+AES.h"
static NSMutableArray *tasks;

@implementation BHRHttpTool

//FQSingletonM//单例.m

+(NSMutableArray *)tasks
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tasks = [[NSMutableArray alloc]init];
    });
    return tasks;
}


+(FQURLSessionTask *)getWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                         success:(FQResponseSuccess)success
                            fail:(FQResponseFail)fail
                         showHUD:(BOOL)showHUD
{
    
    return [self baseRequestType:0 url:url params:params  success:success fail:fail showHUD:showHUD];
    
}
+(FQURLSessionTask *)postWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                       headParams:(NSDictionary*)headParams
                          success:(FQResponseSuccess)success
                             fail:(FQResponseFail)fail
                          showHUD:(BOOL)showHUD
{
    
    return [self baseRequestType:1 url:url params:params headParams:headParams success:success fail:fail showHUD:showHUD];
    
}
+(FQURLSessionTask *)baseRequestType:(NSUInteger)type
                                  url:(NSString *)url
                               params:(NSDictionary *)params
                           headParams:(NSDictionary*)headParams
                              success:(FQResponseSuccess)success
                                 fail:(FQResponseFail)fail
                              showHUD:(BOOL)showHUD
{
    if (url ==nil)
    {
        return nil;
    }
    
    if (showHUD)
    {
        [MBProgressHUD showHUD];
    }
    
    
    
    //检查地址中是否有中文
    NSString *urlStr = [NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager = [self getAFManager];
    
    if (headParams)
    {
        NSEnumerator * enumeratorKey = [headParams keyEnumerator];
        NSString *keyString ;
        for (NSObject *object in enumeratorKey)
        {
            keyString = [NSString stringWithFormat:@"%@",object];
            [manager.requestSerializer setValue:headParams[keyString] forHTTPHeaderField:keyString];
        }
    }
    
    FQURLSessionTask *sessionTask = nil;
    
    if (type==0)
    {
        sessionTask = [manager GET:urlStr parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //                        QDLog(@"成功请求结果=%@",responseObject);
            if (success)
            {
                success(responseObject);
            }
            
            [[self tasks]removeObject:sessionTask];
            
            if (showHUD)
            {
                [MBProgressHUD dissmiss];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //                        QDLog(@"error=%@",error);
            
            if (fail)
            {
                fail(error);
            }
            
            [[self tasks]removeObject:sessionTask];
            
            if (showHUD)
            {
                [MBProgressHUD dissmiss];
            }
        }];
    }else if(type == 1)
    {
        sessionTask = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //                        QDLog(@"请求成功=%@",responseObject);
            if (success)
            {
                success(responseObject);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES)
            {
                [MBProgressHUD dissmiss];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //            QDLog(@"error=%@",error);
            if (fail)
            {
                fail(error);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES)
            {
                [MBProgressHUD dissmiss];
            }
            
        }];
    }
    else if (type == 2)
    {
        //delete
        
        sessionTask = [manager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (success)
            {
                success(responseObject);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES)
            {
                [MBProgressHUD dissmiss];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (fail)
            {
                fail(error);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES)
            {
                [MBProgressHUD dissmiss];
            }
            
        }];
    }
    
    if (sessionTask)
    {
        [[self tasks]addObject:sessionTask];
    }
    
    return sessionTask;
}

+(FQURLSessionTask *)postWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                          success:(FQResponseSuccess)success
                             fail:(FQResponseFail)fail
                          showHUD:(BOOL)showHUD
{
    
    return [self baseRequestType:1 url:url params:params  success:success fail:fail showHUD:showHUD];
    
}

+(FQURLSessionTask *)deleteWithUrl:(NSString *)url
                             params:(NSDictionary *)params
                         headParams:(NSDictionary*)headParams
                            success:(FQResponseSuccess)success
                               fail:(FQResponseFail)fail
                            showHUD:(BOOL)showHUD
{
    
    return [self baseRequestType:2 url:url params:params  success:success fail:fail showHUD:showHUD];
    
}



+(FQURLSessionTask *)baseRequestType:(NSUInteger)type
                                  url:(NSString *)url
                               params:(NSDictionary *)params
                              success:(FQResponseSuccess)success
                                 fail:(FQResponseFail)fail
                              showHUD:(BOOL)showHUD
{
    if (url ==nil)
    {
        return nil;
    }
    
    if (showHUD)
    {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    }
    
    
    //检查地址中是否有中文
    NSString *urlStr = [NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager = [self getAFManager];

    NSMutableDictionary *headParams = [NSMutableDictionary dictionaryWithCapacity:0];
    [headParams setValue:[Utils getImeiNumber] forKey:@"imei"];
    [headParams setValue:@"IOS" forKey:@"device"];
    NSString *wasLogin = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN];
    [headParams setValue:wasLogin.length > 0 ? [@"Bearer "stringByAppendingFormat:@"%@",UserDefaultObjectForKey(ACCESS_TOKEN)] :nil forKey:AUTHORIZATION];
    [headParams setValue:ACCEPT_LANGUAGE forKey:@"Accept-Language"];
    [headParams setValue:APP_VERSION forKey:@"version"];
    [headParams setValue:APPID forKey:@"appId"];
    [headParams setValue:BUSINESSID forKey:@"businessId"];
    [headParams setValue:@"appStore" forKey:@"channel"];
    [headParams setValue:CurrentSystemVersion forKey:@"os"];
    [headParams setValue:[Utils deviceModelName] forKey:@"deviceType"];
    NSEnumerator * enumeratorKey = [headParams keyEnumerator];
    NSString *keyString ;
    for (NSObject *object in enumeratorKey)
    {
        keyString = [NSString stringWithFormat:@"%@",object];
        [manager.requestSerializer setValue:headParams[keyString] forHTTPHeaderField:keyString];
    }
    //    }
    
    FQURLSessionTask *sessionTask = nil;

    
    if (type==0)
    {
        sessionTask = [manager GET:urlStr parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (showHUD)
            {
                
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            }
            //                        QDLog(@"成功请求结果=%@",responseObject);
            if (success)
            {
                success(responseObject);
            }
            
            [[self tasks]removeObject:sessionTask];
            
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //                        QDLog(@"error=%@",error);
            
            if (fail)
            {
                fail(error);
            }
            
            [[self tasks]removeObject:sessionTask];
            
            if (showHUD ==YES)
            {
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            }
        }];
    }else if(type == 1)
    {
        //数据编码并加密
        NSData * jData = [NSJSONSerialization dataWithJSONObject:params==nil? @{}:params options:0 error:nil];
        NSString * jStr = [[NSString alloc]initWithData:jData encoding:NSUTF8StringEncoding];
        NSString * aesStr = [SecurityUtil encryptAESData:jStr];
        NSData * data = [aesStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSData * data = [jStr dataUsingEncoding:NSUTF8StringEncoding];

        //设置请求规则
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        manager.responseSerializer =[AFHTTPResponseSerializer serializer];
        //设置request
        NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
         NSString *length = [NSString stringWithFormat:@"%ld", [jData length]];
         [request setValue:length forHTTPHeaderField:@"Content-Length"]; //设置数据长度
         [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

        NSEnumerator * enumeratorKey = [headParams keyEnumerator];
        NSString *keyString ;
        for (NSObject *object in enumeratorKey)
        {
            keyString = [NSString stringWithFormat:@"%@",object];
            [request setValue:headParams[keyString] forHTTPHeaderField:keyString];
        }
        [request setHTTPBody:data];

        sessionTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
         
            if (error) {//请求发生错误的时候请求
                if (showHUD ==YES)
                {
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
                }
                if (fail)
                {
                    fail(error);
                }
    
                [[self tasks] removeObject:sessionTask];
                [Utils showToast:@"网络连接错误"];
                
            }else{//请求成功
      
     
                //接收加密信息并编码解析
                NSString * dataStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSString * desStr = [SecurityUtil decryptAESData:dataStr];
                NSData * desData = [desStr dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary * desDict = [NSJSONSerialization JSONObjectWithData:desData options:0 error:nil];
                if (success)
                {
                    success([self deleteEmpty:desDict]);
                }
                if (showHUD)
                {
                    [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
                }
                [[self tasks] removeObject:sessionTask];
    
    
                
            }
        }];
        [sessionTask resume];

//        sessionTask = [manager POST:url parameters:jStr progress:^(NSProgress * _Nonnull uploadProgress) {
//
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            //                        QDLog(@"请求成功=%@",responseObject);
//            if (showHUD)
//            {
//                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
//            }
//
//
//
//            if (success)
//            {
//                success([self deleteEmpty:responseObject]);
//            }
//
//            [[self tasks] removeObject:sessionTask];
//
//
//
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            //            QDLog(@"error=%@",error);
//            if (showHUD ==YES)
//            {
//                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
//            }
//            if (fail)
//            {
//                fail(error);
//            }
//
//            [[self tasks] removeObject:sessionTask];
//
//
//
//        }];
    }
    else if (type == 2)
    {
        //delete
        
        sessionTask = [manager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (success)
            {
                success(responseObject);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD==YES)
            {
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (fail)
            {
                fail(error);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            if (showHUD ==YES)
            {
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            }
            
        }];
    }
  
    if (sessionTask)
    {
        [[self tasks]addObject:sessionTask];
    }
    
    return sessionTask;
}
+(FQURLSessionTask *)postNoEncodeWithUrl:(NSString *)url
                                  params:(NSDictionary *)params
                                 success:(FQResponseSuccess)success
                                    fail:(FQResponseFail)fail
                                 showHUD:(BOOL)showHUD{
    
    if (url ==nil)
    {
        return nil;
    }
    
    if (showHUD)
    {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    }
    
    
    //检查地址中是否有中文
    NSString *urlStr = [NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager = [self getAFManager];
    
    NSMutableDictionary *headParams = [NSMutableDictionary dictionaryWithCapacity:0];
    [headParams setValue:[Utils getImeiNumber] forKey:@"imei"];
    [headParams setValue:@"IOS" forKey:@"device"];
    NSString *wasLogin = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN];
    [headParams setValue:wasLogin.length > 0 ? [@"Bearer "stringByAppendingFormat:@"%@",UserDefaultObjectForKey(ACCESS_TOKEN)] :nil forKey:AUTHORIZATION];
    [headParams setValue:ACCEPT_LANGUAGE forKey:@"Accept-Language"];
    [headParams setValue:APP_VERSION forKey:@"version"];
    [headParams setValue:APPID forKey:@"appId"];
    [headParams setValue:BUSINESSID forKey:@"businessId"];
    [headParams setValue:@"appStore" forKey:@"channel"];
    
    NSEnumerator * enumeratorKey = [headParams keyEnumerator];
    NSString *keyString ;
    for (NSObject *object in enumeratorKey)
    {
        keyString = [NSString stringWithFormat:@"%@",object];
        [manager.requestSerializer setValue:headParams[keyString] forHTTPHeaderField:keyString];
    }
    //    }
    
    FQURLSessionTask *sessionTask = nil;

        sessionTask = [manager POST:urlStr parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //                        QDLog(@"请求成功=%@",responseObject);
            if (showHUD)
            {
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            }
            if (success)
            {
                success([self deleteEmpty:responseObject]);
            }
            
            [[self tasks] removeObject:sessionTask];
            
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //            QDLog(@"error=%@",error);
            if (showHUD ==YES)
            {
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
            }
            if (fail)
            {
                fail(error);
            }
            
            [[self tasks] removeObject:sessionTask];
            
        }];
    
    if (sessionTask)
    {
        [[self tasks]addObject:sessionTask];
    }
    
    return sessionTask;
    
}
//删除字典里的null值
+ (NSDictionary *)deleteEmpty:(NSDictionary *)dic
{
    NSMutableDictionary *mdic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    NSMutableArray *set = [[NSMutableArray alloc] init];
    NSMutableDictionary *dicSet = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *arrSet = [[NSMutableDictionary alloc] init];
    for (id obj in mdic.allKeys)
    {
        id value = mdic[obj];
        if ([value isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *changeDic = [self deleteEmpty:value];
            [dicSet setObject:changeDic forKey:obj];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            NSArray *changeArr = [self deleteEmptyArr:value];
            [arrSet setObject:changeArr forKey:obj];
        }
        else
        {
            if ([value isKindOfClass:[NSNull class]]) {
                [set addObject:obj];
            }
        }
    }
    for (id obj in set)
    {
        mdic[obj] = @"";
    }
    for (id obj in dicSet.allKeys)
    {
        mdic[obj] = dicSet[obj];
    }
    for (id obj in arrSet.allKeys)
    {
        mdic[obj] = arrSet[obj];
    }
    
    return mdic;
}
//删除数组中的null值
+ (NSArray *)deleteEmptyArr:(NSArray *)arr
{
    NSMutableArray *marr = [NSMutableArray arrayWithArray:arr];
    NSMutableArray *set = [[NSMutableArray alloc] init];
    NSMutableDictionary *dicSet = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *arrSet = [[NSMutableDictionary alloc] init];
    
    for (id obj in marr)
    {
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *changeDic = [self deleteEmpty:obj];
            NSInteger index = [marr indexOfObject:obj];
            [dicSet setObject:changeDic forKey:@(index)];
        }
        else if ([obj isKindOfClass:[NSArray class]])
        {
            NSArray *changeArr = [self deleteEmptyArr:obj];
            NSInteger index = [marr indexOfObject:obj];
            [arrSet setObject:changeArr forKey:@(index)];
        }
        else
        {
            if ([obj isKindOfClass:[NSNull class]]) {
                NSInteger index = [marr indexOfObject:obj];
                [set addObject:@(index)];
            }
        }
    }
    for (id obj in set)
    {
        marr[(int)obj] = @"";
    }
    for (id obj in dicSet.allKeys)
    {
        int index = [obj intValue];
        marr[index] = dicSet[obj];
    }
    for (id obj in arrSet.allKeys)
    {
        int index = [obj intValue];
        marr[index] = arrSet[obj];
    }
    return marr;
}

+(FQURLSessionTask *)uploadWithImage:(NSData *)imageData
                                  url:(NSString *)url
                             filename:(NSString *)filename
                                 name:(NSString *)name
                               params:(NSDictionary *)params
                           headParams:(NSDictionary *)headParams
                             progress:(FQUploadProgress)progress
                              success:(FQResponseSuccess)success
                                 fail:(FQResponseFail)fail
                              showHUD:(BOOL)showHUD
{
    //    QDLog(@"请求地址----%@\n    请求参数----%@",url,params);
    
    if (url==nil)
    {
        return nil;
    }
    
    if (showHUD==YES)
    {
        [MBProgressHUD showHUD];
    }
    
    //检查地址中是否有中文
    NSString *urlStr=[NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager=[self getAFManager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSMutableDictionary *headDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [headDict setValue:[Utils getImeiNumber] forKey:@"imei"];
    [headDict setValue:@"IOS" forKey:@"device"];
    [headDict setValue:ACCEPT_LANGUAGE forKey:@"Accept-Language"];
    [headDict setValue:APP_VERSION forKey:@"version"];
    [headDict setValue:APPID forKey:@"appId"];
    [headDict setValue:BUSINESSID forKey:@"businessId"];
    NSString *wasLogin = [[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN];
    [headDict setValue:wasLogin.length > 0 ? [@"Bearer "stringByAppendingFormat:@"%@",UserDefaultObjectForKey(ACCESS_TOKEN)] :nil forKey:AUTHORIZATION];

    if (headParams!=nil)
    {
        NSEnumerator * enumeratorKey = [headParams keyEnumerator];
        NSString *keyString ;
        for (NSObject *object in enumeratorKey)
        {
            keyString = [NSString stringWithFormat:@"%@",object];
            [manager.requestSerializer setValue:headParams[keyString] forHTTPHeaderField:keyString];
        }
    }else{
        NSEnumerator * enumeratorKey = [headDict keyEnumerator];
        NSString *keyString ;
        for (NSObject *object in enumeratorKey)
        {
            keyString = [NSString stringWithFormat:@"%@",object];
            [manager.requestSerializer setValue:headParams[keyString] forHTTPHeaderField:keyString];
        }
    }
    
    
    FQURLSessionTask *sessionTask = [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //        压缩图片
        //        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        
        // 上传图片，以文件流的格式
        [formData appendPartWithFileData:imageData name:name fileName:imageFileName mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //        QDLog(@"上传进度--%lld,总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        if (progress)
        {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //接收加密信息并编码解析
        NSString * dataStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString * desStr = [SecurityUtil decryptAESData:dataStr];
        NSData * desData = [desStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * desDict = [NSJSONSerialization JSONObjectWithData:desData options:0 error:nil];
        
        //               QDLog(@"上传图片成功=%@",responseObject);
        if (success)
        {
            success([self deleteEmpty:desDict]);
//            success([NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil]);
        }
        
        [[self tasks] removeObject:sessionTask];
        
        if (showHUD==YES)
        {
            [MBProgressHUD dissmiss];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //                QDLog(@"error=%@",error);
        if (fail)
        {
            fail(error);
        }
        
        [[self tasks] removeObject:sessionTask];
        
        if (showHUD==YES)
        {
            [MBProgressHUD dissmiss];
        }
        
    }];
    
    
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
    
}

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
                             showHUD:(BOOL)showHUD
{
    //    QDLog(@"请求地址----%@\n    请求参数----%@",url,params);
    
    if (url==nil)
    {
        return nil;
    }
    
    if (showHUD==YES)
    {
        [MBProgressHUD showHUD];
    }
    
    //检查地址中是否有中文
    NSString *urlStr=[NSURL URLWithString:url]?url:[self strUTF8Encoding:url];
    
    AFHTTPSessionManager *manager=[self getAFManager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
  
    if (headParams)
    {
        NSEnumerator * enumeratorKey = [headParams keyEnumerator];
        NSString *keyString ;
        for (NSObject *object in enumeratorKey)
        {
            keyString = [NSString stringWithFormat:@"%@",object];
            [manager.requestSerializer setValue:headParams[keyString] forHTTPHeaderField:keyString];
        }
    }
    
    
    FQURLSessionTask *sessionTask = [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
                                      {
                                          [formData appendPartWithFileData:data name:name fileName:filename mimeType:@""];
                                      } progress:^(NSProgress * _Nonnull uploadProgress)
                                      {
                                          if (progress)
                                          {
                                              progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
                                          }
                                      } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                                      {
                                          
                                          //接收加密信息并编码解析
                                          NSString * dataStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                                          NSString * desStr = [SecurityUtil decryptAESData:dataStr];
                                          NSData * desData = [desStr dataUsingEncoding:NSUTF8StringEncoding];
                                          NSDictionary * desDict = [NSJSONSerialization JSONObjectWithData:desData options:0 error:nil];
                                          
                                          //               QDLog(@"上传图片成功=%@",responseObject);
                                          if (success)
                                          {
                                              success([self deleteEmpty:desDict]);
//                                              success([NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil]);
                                          }
                                          
                                          [[self tasks] removeObject:sessionTask];
                                          
                                          if (showHUD==YES)
                                          {
                                              [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
                                          }
                                          
                                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
                                      {
                                          if (fail)
                                          {
                                              fail(error);
                                          }
                                          
                                          [[self tasks] removeObject:sessionTask];
                                          
                                          if (showHUD==YES)
                                          {
                                              [MBProgressHUD dissmiss];
                                          }
                                          
                                      }];
    
    
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
    
}



+ (FQURLSessionTask *)downloadWithUrl:(NSString *)url
                            saveToPath:(NSString *)saveToPath
                              progress:(FQDownloadProgress)progressBlock
                               success:(FQResponseSuccess)success
                               failure:(FQResponseFail)fail
                               showHUD:(BOOL)showHUD
{
    
    //    QDLog(@"请求地址----%@\n    ",url);
    if (url==nil)
    {
        return nil;
    }
    
    if (showHUD==YES)
    {
        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    }
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPSessionManager *manager = [self getAFManager];
    
    FQURLSessionTask *sessionTask = nil;
    
    sessionTask = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        //        QDLog(@"下载进度--%.1f",1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        //回到主线程刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock)
            {
                progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (!saveToPath)
        {
            
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            //            QDLog(@"默认路径--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
            
        }
        else
        {
            return [NSURL fileURLWithPath:saveToPath];
            
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error){
        //        QDLog(@"下载文件成功");
        
        [[self tasks] removeObject:sessionTask];
        
        if (error == nil)
        {
            if (success)
            {
                success([filePath path]);//返回完整路径
            }
            
        }
        else
        {
            if (fail)
            {
                fail(error);
            }
            
        }
        
        if (showHUD==YES)
        {
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].delegate.window animated:YES];
        }
        
    }];
    
    //开始启动任务
    [sessionTask resume];
    
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    
    return sessionTask;
    
    
}

+(AFHTTPSessionManager *)getAFManager{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = manager = [AFHTTPSessionManager manager];
    
    //设置证书--解决 https 问题
    //    manager.securityPolicy.validatesDomainName = YES;
    //    manager.securityPolicy.allowInvalidCertificates = NO;
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//设置请求数据为json
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//设置返回数据为json
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval=120;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
//
    return manager;
    
}

#pragma makr - 开始监听网络连接

- (void)startMonitoring
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         // 当网络状态改变了, 就会调用这个bloc
         switch (status)
         {
             case AFNetworkReachabilityStatusUnknown: // 未知网络
                 //                 QDLog(@"未知网络");
                 //                  [Utils showToast:@"网络错误，请检查网络设置"];
                 self.networkStats=StatusUnKnown;
                 break;
             case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                 //                 QDLog(@"没有网络");
                 //                 [Utils showToast:@"网络错误，请检查网络设置"];
                 self.networkStats=StatusNotReachable;
                 break;
             case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                 //                 QDLog(@"手机自带网络");
                 self.networkStats=StatusReachableWWAN;
                 break;
             case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                 //                 QDLog(@"WIFI网络");
                 self.networkStats=StatusReachableWiFI;
                 break;
         }
     }];
    
    [mgr startMonitoring];
}

+(NSData*)obtinImagePercent:(UIImage *)image
{
    
    NSData * imageData;
    NSData * imageData1 = UIImageJPEGRepresentation(image, 1);
    if ([imageData1 length]/1024<1000){
        imageData = imageData1;
    }
    else if ([imageData1 length]/1024<=2000&& [imageData1 length]/1024 >=1000 ) {
        imageData = UIImageJPEGRepresentation([BHRHttpTool imageByScalingAndCroppingForSize:image.size proImage:image], 0.8);
        if ([imageData1 length]/1024<200) {
            imageData = UIImageJPEGRepresentation([BHRHttpTool imageByScalingAndCroppingForSize:image.size proImage:image], 1);
        }
    }
    else{
        imageData = UIImageJPEGRepresentation([BHRHttpTool imageByScalingAndCroppingForSize:image.size proImage:image], 0.5);
        if ([imageData length]/1024 <200) {
            imageData = UIImageJPEGRepresentation([BHRHttpTool imageByScalingAndCroppingForSize:image.size proImage:image], 0.7);
        }
    }
    
    
    //    NSInteger options;
    //
    //    NSInteger len = [imageData length]/1024;
    //    if(len < 1000){
    //        options = 100;
    //    } else if(len >= 1000 && len < 2000){
    //        options = 90;
    //    }else if(len >= 2000 && len < 3000){
    //        options = 99;
    //    }
    //    else
    //    {
    //        options=30;
    //    }
    //    NSData * yasuoImageData = UIImageJPEGRepresentation(image, options/100);
    //
    UIImage * yaosuo =[UIImage imageWithData:imageData];
    return imageData;
}
+(NSString *)strUTF8Encoding:(NSString *)str
{
    //return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:str];
    NSString *encodedString = [str stringByAddingPercentEncodingWithAllowedCharacters:charset];
    return encodedString;
}
//图片压缩到指定大小
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize proImage:(UIImage*)proimage
{
    UIImage *sourceImage = proimage;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        //        CGFloat widthFactor = targetWidth / width;
        //        CGFloat heightFactor = targetHeight / height;
        CGFloat widthFactor = 0.9;
        CGFloat heightFactor = 0.9;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end

