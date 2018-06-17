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

