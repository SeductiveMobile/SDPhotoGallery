//
//  UIGalleryToServer.m
//  Pods
//
//  Created by Bohdan on 07.07.15.
//
//

#import "UIGalleryToServer.h"
#import "SBAPIManager.h"
#import "TWPhotoStruct.h"

@implementation UIGalleryToServer

+(void) deletePhotoWithParams:(NSDictionary *)params url:(NSString*)url  success:(void (^) (id responseObject))handler failure:(void (^) (NSError *error))failureHandler {
    [[SBAPIManager sharedManager] POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        handler(@"DELETED");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureHandler(error);
    }];
}

+(void) uploadImageWithParams:(NSDictionary *)params url:(NSString*)url iamge:(NSData *)imageData success:(void (^) (id responseObject))handler failure:(void (^) (NSError *error))failureHandler progress:(void (^) (float progressValue))progress {

    AFHTTPRequestOperation *operation = [[SBAPIManager sharedManager] POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"uploadfile"
                                fileName:@"uploadfile" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        handler(handler);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureHandler(error);
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        float progressUploaded = totalBytesWritten * 100.0f / totalBytesExpectedToWrite;
        progress (progressUploaded);
    }];
}


+(void) loadPhotosWithParams:(NSDictionary *)params url:(NSString*)url success:(void (^) (id responseObject))handler failure:(void (^) (NSError *error))failureHandler {
    [[SBAPIManager sharedManager] GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *errorMessage;
        NSArray * responseObjects = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&errorMessage];
        NSMutableArray * results = [[NSMutableArray alloc] initWithCapacity:[responseObjects count]];
        
        for (NSDictionary * dict in responseObjects) {
            TWPhotoStruct * photo = [[TWPhotoStruct alloc] initWithDictionary:dict error:&errorMessage];
            if (!errorMessage) {
                [results addObject:photo];
            } else {
                failureHandler(errorMessage);
                return;
            }
        }
        if (!errorMessage) {
            handler(results);
        } else {
            failureHandler(errorMessage);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureHandler(error);
    }];
}

@end
