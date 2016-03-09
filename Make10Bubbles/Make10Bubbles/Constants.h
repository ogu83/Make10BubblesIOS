//
//  Constants.h
//  Make10Bubbles
//
//  Created by Oğuz Köroğlu on 23/02/16.
//  Copyright © 2016 Oguz Koroglu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

extern NSString *const WebSite;
extern NSString *const GameName;
extern NSString *const AppId;
extern NSString *const ApiAddress;
extern NSString *const TwitterAddress;
extern NSString *const FacebookAddress;
extern NSString *const FacebookAppId;
extern NSString *const FacebookAppSecret;
@end
