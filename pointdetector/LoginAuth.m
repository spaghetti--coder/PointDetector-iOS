//
//  LoginAuth.m
//  pointdetector
//
//  Created by  on 13/08/06.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import "LoginAuth.h"

@implementation LoginAuth

@synthesize connection;
@synthesize receivedData;
@synthesize isFirstLogin;

- (NSString*) _uriEncodeForString:(NSString *)str {
    return ((__bridge_transfer NSString*)
            CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                    (__bridge_retained CFStringRef)str,
                                                    NULL,
                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                    kCFStringEncodingUTF8));
}

- (NSString*) _buildParameters:(NSDictionary *)params {
    NSMutableString *s = [NSMutableString string];
    
    NSString *key;
    for ( key in params ) {
        NSString *uriEncodedValue = [self _uriEncodeForString:[params objectForKey:key]];
        [s appendFormat:@"%@=%@&", key, uriEncodedValue];
    }
    
    if ( [s length] > 0 ) {
        [s deleteCharactersInRange:NSMakeRange([s length]-1, 1)];
    }
    return s;
}

- (void) post:(NSURL *)url withParameters:(NSDictionary *)params flag:(BOOL)flag {
    
    // ユーザー名とパスワードが入力されているかどうかを確認する
    NSString *key;
    for (key in params) {
        
        if ([key isEqualToString:@"username"]) {
            
            if ([[params objectForKey:key] isEqualToString:@""]) {
                
                if (userInfo == nil) {
                    userInfo = [[UserInfo alloc] init];
                }
                userInfo.result = NO;
                userInfo.message = @"ユーザー名が入力されていません。";
                [self loginFailure];
                return;
                
            }
            
        } else if ([key isEqualToString:@"password"]) {
            
            if ([[params objectForKey:key] isEqualToString:@""]) {
                
                if (userInfo == nil) {
                    userInfo = [[UserInfo alloc] init];
                }
                userInfo.result = NO;
                userInfo.message = @"パスワードが入力されていません。";
                [self loginFailure];
                return;
                
            }
            
        }
        
    }
    
    // ユーザー名などを先に保存しておく
    userName = [params objectForKey:@"username"];;
    isFirstLogin = flag;
    
    // BODY の作成
    NSString *bodyString = [self _buildParameters:params];
    NSData   *httpBody   = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url
        cachePolicy:NSURLRequestReloadIgnoringCacheData
        timeoutInterval:HTTP_TIMEOUT];
    
//- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately NS_AVAILABLE(10_5, 2_0);
    
    // POST の HTTP Request を作成
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded"                 forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%d", [httpBody length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:httpBody];
    [req setHTTPShouldHandleCookies:YES];
    
    // POST 送信
    NSLog(@"sending [%@] (%d bytes) to %@ ...", bodyString, [httpBody length], url);
    self.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    self.receivedData = [[NSMutableData alloc] init];
    
    if ( self.connection ) {
        self.receivedData = [NSMutableData data];
    } else {
        
        if (userInfo == nil) {
            userInfo = [[UserInfo alloc] init];
        }
        
        userInfo.result = NO;
        userInfo.message = @"接続が確立できませんでした。";
        NSLog(@"creating NSURLConnection failed: in %s", __FUNCTION__);
    }
    
}

/* ------------------
 * ログイン成功or失敗
 * ------------------ */

// ログイン成功時の処理
- (void) loginSuccess
{
    
    TargetPoint *tp = [[TargetPoint alloc] init];
    
    if (isFirstLogin) { // 初回ログインであれば、地点情報を強制的に更新
        
        [tp targetpoints:[NSString stringWithCString:SERVER encoding:NSUTF8StringEncoding] flag:YES];
        
    } else {
        
        [tp targetpoints:[NSString stringWithCString:SERVER encoding:NSUTF8StringEncoding] flag:NO];
        
    }
    
    // 設定値を読み書き
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:userName forKey:@"userName"];
    [defaults setInteger:userInfo.user_id forKey:@"userID"];
    [defaults setInteger:userInfo.set_point forKey:@"pointID"];
    [defaults setObject:userInfo.login_hash forKey:@"loginHash"];
    
    targetPoints = [defaults objectForKey:@"targetPoints"];
    
    // 取得したpointIDに対応する地点名を取得
    NSString *pn = @"";
    NSString *alertMessage = @"正常にログインできました。";
    NSEnumerator* placeEnumerator = [targetPoints objectEnumerator];
    id places = nil;
    
    if (placeEnumerator != nil) {
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
            
            if (userInfo.set_point == pd.pointID) {
                
                pn = pd.pointName;
                [defaults setObject:pd.pointName forKey:@"pointName"];
                [defaults setDouble:pd.latitude forKey:@"pointLatitude"];
                [defaults setDouble:pd.latitude forKey:@"pointLongitude"];
                
            }
            
        }
    }
    
    if (pn != nil && ![pn isEqualToString:@""]) {
        alertMessage = [NSString stringWithFormat:@"正常にログインできました。\n(現在の設定目標地点:%@)", pn];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"ログイン成功"
                              message:alertMessage
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
}

// ログイン失敗時の処理
- (void) loginFailure
{
    
    if ([userInfo.message isEqualToString:@"NO username"]) {
        userInfo.message = @"ユーザー名を入力してください";
    } else if ([userInfo.message isEqualToString:@"NO password"]) {
        userInfo.message = @"パスワードを入力してください。";
    } else if ([userInfo.message isEqualToString:@"Failed to Login"]) {
        userInfo.message = @"ユーザー名またはパスワードが間違っています。";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"ログイン失敗"
                              message:userInfo.message
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
}

/* ------------------
 * デリゲートメソッド
 * ------------------ */

// 受信開始時
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    userInfo = [[UserInfo alloc] init];
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
    
    // 取得したNSData型のオブジェクトから、JSONのパースを行う
    NSData *jsonData = receivedData;
    
    // JSON を NSDictionary に変換する
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingAllowFragments
                                                       error:&error];
    
    // 正常なJSONデータであれば、値を代入する
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        for (id key in dict) {
            userInfo.user_id = [[dict objectForKey:@"user_id"] intValue];
            userInfo.set_point = [[dict objectForKey:@"set_point"] intValue];
            userInfo.login_hash = [dict objectForKey:@"login_hash"];
            userInfo.result = [[dict objectForKey:@"result"] boolValue];
            userInfo.message = [dict objectForKey:@"message"];
        }
        
        // 出力確認用(result以外はすべて__NSCFString型)
//        NSLog(@"\n[JSON]\n");
//        NSLog(@"user_id: %@", userInfo.user_id);
//        NSLog(@"set_point: %@", userInfo.set_point);
//        NSLog(@"login_hash: %@", userInfo.login_hash);
//        NSLog(@"result: %@", userInfo.result); // __NSCFBoolean
//        NSLog(@"message: %@", userInfo.message);
//        NSLog(@"%@", NSStringFromClass([userInfo.user_id class]));
//        NSLog(@"%@", NSStringFromClass([userInfo.set_point class]));
//        NSLog(@"%@", NSStringFromClass([userInfo.login_hash class]));
//        NSLog(@"%@", NSStringFromClass([userInfo.result class]));
//        NSLog(@"%@", NSStringFromClass([userInfo.message class]));
        
        if (userInfo.result == YES) { // result→true(YES,TRUE)であれば、ログイン成功
            
            [self loginSuccess];
            
        } else { // そうでなければ、ログイン失敗
            
            [self loginFailure];
            
        }
        
    } else {
        
        userInfo.message = @"ログインに失敗しました。";
        [self loginFailure]; // データ解釈に失敗→ログイン失敗
        
    }
    
}

// 受信エラー
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    userInfo.message = @"通信エラーが発生し、ログインできませんでした。";
    [self loginFailure]; // 受信エラー→ログイン失敗
    
}

@end
