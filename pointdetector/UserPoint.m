//
//  UserPoint.m
//  pointdetector
//
//  Created by  on 13/08/08.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "UserPoint.h"

@implementation UserPoint

@synthesize connection;
@synthesize receivedData;
@synthesize message;
@synthesize sending;

- (void) setUserPoint:(NSString *)url userName:(NSString *)userName
             latitude:(double)latitude longitude:(double)longitude
            timeStamp:(UInt64)timeStamp hashClient:(NSString *)hashClient
{
    
    NSMutableString *_url = [NSMutableString string];
    [_url appendFormat:@"%@report/location/", url];
    [_url appendString:userName];
    [_url appendFormat:@"/%f,%f/%llu/", latitude, longitude, timeStamp];
    [_url appendString:hashClient];
    
    NSURL *sendUrl = [NSURL URLWithString:_url];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:sendUrl
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:HTTP_TIMEOUT];
    
    // HTTP Request を作成
    [req setHTTPMethod:@"GET"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPShouldHandleCookies:YES];
    
    // GET 送信
    self.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    self.receivedData = [[NSMutableData alloc] init];
    
    if ( self.connection ) {
        
        self.receivedData = [NSMutableData data];
        
    } else {
        
        if (message == nil) {
            
            message = [[Message alloc] init];
            
        }
        message.result = NO;
        message.message = @"接続を確立できませんでした。";
        
        NSLog(@"creating NSURLConnection failed: in %s", __FUNCTION__);
        
    }
    
}

- (void) userPointsSuccessSetting
{
    
    sending = NO;
    NSLog(@"[success] user point was sent to server.");
    
}

- (void) userPointsFailure
{
    sending = NO;
    NSLog(@"[failure] user point couldn't report/resolve.");
    
}

/* ------------------
 * デリゲートメソッド
 * ------------------ */

// 受信開始時
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    if (message == nil) {
        message = [[Message alloc] init];
    }
    
    receivedData = [[NSMutableData alloc] init];
    
}

// 受信中
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [receivedData appendData:data];
    
}

// 受信完了
- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (sending) {
        NSLog(@"process other data... abort this method");
        return;
    }
    sending = YES;
    
    NSData *jsonData = receivedData;
    NSError *error = nil;
    
    // JSON を NSDictionary に変換する
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        
        for (id key in dict) {
            message.result = [[dict objectForKey:@"result"] boolValue];
            message.message = [dict objectForKey:@"message"];
        }
        
        if (message.result) {
            
            [self userPointsSuccessSetting];
            
        } else {
            
            [self userPointsFailure];
            
        }
        
    } else {
        
        message.result = NO;
        message.message = @"ユーザー地点の送信結果を取得できませんでした。";
        [self userPointsFailure];
        
    }
    
}

// 受信エラー
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    message.result = NO;
    message.message = @"通信エラーが発生し、正常に処理できませんでした。";
    [self userPointsFailure];
    
}

@end
