//
//  LoginAuth.h
//  pointdetector
//
//  Created by  on 13/08/06.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "TargetPoint.h"

#define HTTP_TIMEOUT 30
#define SERVER "http://www15052ui.sakura.ne.jp/"

@interface LoginAuth : NSObject {
    id connection;
    NSMutableData *receivedData;
    NSMutableArray *targetPoints;
    NSString *userName;
    UserInfo *userInfo;
    BOOL isFirstLogin;
}
@property (nonatomic, strong) id connection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic) BOOL isFirstLogin;

- (NSString*) _uriEncodeForString:(NSString *)str;
- (NSString*) _buildParameters:(NSDictionary *)params;
- (void) post:(NSURL *)url withParameters:(NSDictionary *)params flag:(BOOL)flag;
- (void) loginSuccess;
- (void) loginFailure;

@end
