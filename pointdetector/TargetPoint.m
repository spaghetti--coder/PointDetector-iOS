//
//  TargetPoint.m
//  pointdetector
//
//  Created by  on 13/08/07.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import "TargetPoint.h"

@implementation TargetPoint

@synthesize connection;
@synthesize receivedData;
@synthesize targetPoints;
@synthesize message;
@synthesize isFirstLogin;

int mode = TP_NONE;

/* ------------------
 * 目標地点取得・
 * アプリ内保存部
 * ------------------ */

- (void) targetpoints:(NSString *)url flag:(BOOL)flag
{
    
    if (mode == TP_SETTER) {
        return;
    }
    mode = TP_GETTER;
    isFirstLogin = flag;
    
    NSMutableString *_url = [NSMutableString string];
    [_url appendFormat:@"%@/target/location/all", url];
    
    NSURL *sendUrl = [NSURL URLWithString:_url];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:sendUrl
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:HTTP_TIMEOUT];
    
    [req setHTTPMethod:@"GET"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPShouldHandleCookies:YES];
    
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

/* ------------------
 * 目標地点設定部
 * ------------------ */

- (void) setTargetPoint:(NSString *)url  userName:(NSString *)userName
                pointID:(int)pointID hashClient:(NSString *)hashClient
{
    
    if (mode == TP_GETTER) {
        return;
    }
    mode = TP_SETTER;
    
    NSMutableString *_url = [NSMutableString string];
//    NSString *parameters = [self _buildParameters:params];
    [_url appendFormat:@"%@/report/target/%@/%d/%@", url, userName, pointID, hashClient];
    
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

/* ------------------
 * 成功or失敗
 * ------------------ */

// 地点一覧取得成功時の処理
- (void) targetPointsSuccessGetting
{
    
    // 設定値を保存/更新
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:targetPoints forKey:@"targetPoints"];
    
    // 初回ログインであれば、設定地点情報も反映させる
    if (isFirstLogin) {
        
        NSLog(@"isFirstLogin is true.\ncurrent pointID is %d", [defaults integerForKey:@"pointID"]);
        
        NSEnumerator* placeEnumerator = [targetPoints objectEnumerator];
        id places = nil;
        
        while (places = [placeEnumerator nextObject]) {
            
            PointDetail *pd = [[PointDetail alloc] init];
            
            NSEnumerator* keyEnumerator = [places keyEnumerator];
            NSEnumerator* objectEnumerator = [places objectEnumerator];
            id key = nil;
            id value = nil;
            
            while (key = [keyEnumerator nextObject]) {
                value = [objectEnumerator nextObject];
                
                if ([key isEqualToString:@"id"]) {
                    pd.pointID = [value intValue];
                } else if ([key isEqualToString:@"point_name"]) {
                    pd.pointName = value;
                } else if ([key isEqualToString:@"latitude"]) {
                    pd.latitude = [value doubleValue];
                } else if ([key isEqualToString:@"longitude"]) {
                    pd.longitude = [value doubleValue];
                }
                pd.timeStamp = 0; // timeStamp is none
                
            }
            
            if ([defaults integerForKey:@"pointID"] == pd.pointID) {
                
                // サーバー側に地点情報を送信し、設定マネージャに保存
                [defaults setObject:pd.pointName forKey:@"pointName"];
                [defaults setDouble:pd.latitude forKey:@"pointLatitude"];
                [defaults setDouble:pd.longitude forKey:@"pointLongitude"];
                
                NSLog(@"[targetPointsSuccessGetting]%@[%f,%f]", pd.pointName, pd.latitude, pd.longitude);
                
            }
            
        }
        
        // GPSの設定に関する情報も書き込む(ONにする)
        [defaults setBool:YES forKey:@"one_time"];
        
    }
    
    NSLog(@"Getting target points is success.");
    
}

// 目標地点変更に成功した時の処理
- (void) targetPointsSuccessSetting
{
    
    if ([message.message isEqualToString:@""]) {
        message.message = @"正常に目標地点を変更できました。";
    } else if ([message.message isEqualToString:@"same_value"]) {
        message.message = @"既に選択された地点に設定されています。";
    }
    
    // 設定値を保存
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"目標地点変更"
                              message:message.message
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
}

// 失敗時の処理
- (void) targetPointsFailure
{
    
    if ([message.message isEqualToString:@""]) {
        message.message = @"何らかのエラーが発生しました。";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"処理失敗"
                              message:message.message
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
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
    
    // 受信した内容を文字列に変換し、コンソールに出力する
//    NSString *output = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
//    NSLog(@"Output: %@", output);
    
    NSData *jsonData = receivedData;
    NSError *error = nil;
    
    // 目標地点取得(NSArray->NSDictionary型で返却)
    if (mode == TP_GETTER) {
        
        NSMutableArray *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
        
        if ([NSJSONSerialization isValidJSONObject:dict]) {
            
            targetPoints = dict;
            
            message.result = YES;
            [self targetPointsSuccessGetting];
            
        } else {
            
            message.result = NO;
            message.message = @"目標地点一覧の取得に失敗しました。";
            [self targetPointsFailure];
            
        }
        
    // 目標地点設定(Message型で返却)
    } else if (mode == TP_SETTER) {
        
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
                
                [self targetPointsSuccessSetting];
                
            } else {
                
                [self targetPointsFailure];
                
            }
            
        } else {
            
            message.result = NO;
            message.message = @"目標地点設定結果を取得できませんでした。";
            [self targetPointsFailure];
            
        }
        
    } else {
        
        message.result = NO;
        message.message = @"エラーが発生し、正常に処理できませんでした。";
        [self targetPointsFailure];
        
    }
    
    mode = TP_NONE; // 処理終了
    
}

// 受信エラー
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    message.result = NO;
    message.message = @"通信エラーが発生し、正常に処理できませんでした。";
    [self targetPointsFailure];
    
    mode = TP_NONE; // 処理終了
    
}

@end
