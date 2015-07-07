//
//  UIGalleryToServer.h
//  Pods
//
//  Created by Bohdan on 07.07.15.
//
//

#import <Foundation/Foundation.h>

@interface UIGalleryToServer : NSObject

+(void) deletePhotoWithParams:(NSDictionary *)params url:(NSString*)url  success:(void (^) (id responseObject))handler failure:(void (^) (NSError *error))failureHandler;
+(void) uploadImageWithParams:(NSDictionary *)params url:(NSString*)url iamge:(NSData *)imageData success:(void (^) (id responseObject))handler failure:(void (^) (NSError *error))failureHandler progress:(void (^) (float progressValue))progress;
+(void) loadPhotosWithParams:(NSDictionary *)params url:(NSString*)url success:(void (^) (id responseObject))handler failure:(void (^) (NSError *error))failureHandler;

@end
