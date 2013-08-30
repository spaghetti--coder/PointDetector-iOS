//
//  FirstViewController.m
//  pointdetector
//
//  Created by  on 13/08/02.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import "FirstViewController.h"

@implementation FirstViewController
@synthesize label_status;
@synthesize label_fps;
@synthesize label_latitude;
@synthesize label_longitude;
@synthesize image_found;

@synthesize isViewAppeared;

@synthesize fps;
@synthesize count;
@synthesize times;
@synthesize flag;
@synthesize previewTime;
@synthesize currentTime;
@synthesize elapsedTime;
@synthesize elapsedTimeList;

@synthesize twitterAccounts;
@synthesize tweetMessage;

@synthesize videoInput;
@synthesize stillImageOutput;
@synthesize session;
@synthesize previewView;

// メモリリーク時
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// ビューが読み込まれたとき(onCreate)
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    isViewAppeared = NO;
    
    // ラベルを初期化する
    label_status.text = [NSString stringWithFormat:@""];
    label_fps.text = [NSString stringWithFormat:@""];
    label_latitude.text = [NSString stringWithFormat:@""];
    label_longitude.text = [NSString stringWithFormat:@""];
	
    // 設定情報を読み込み
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    // ユーザー名とハッシュが既に保存されている→ログイン済
    userName = [[NSString alloc] init];
    loginHash = [[NSString alloc] init]; 
    
    userName = [defaults objectForKey:@"userName"];
    loginHash = [defaults objectForKey:@"loginHash"];
        
    if (userName == nil || loginHash == nil ||
        [userName isEqualToString:@""] || [loginHash isEqualToString:@""]) {
        
        isLogined = NO;
        
    } else {
        
        isLogined = YES;
        
    }
    
    // 目標地点情報を取得
    targetName = [[NSString alloc] init];
    targetName = [defaults objectForKey:@"pointName"];
    targetLatitude = [defaults doubleForKey:@"pointLatitude"];
    targetLongitude = [defaults doubleForKey:@"pointLongitude"];
    if ([targetName isEqualToString:@""] || targetLatitude == 0 || targetLongitude == 0) {
        
        label_status.text = [NSString stringWithFormat:@"ログインしてください"];
        isLogined = NO;
        
    }
    
    // ログイン状態によってメッセージ表示を切り分ける
    if (isLogined) {
        
        label_status.text = @"現在地取得中…";
        [self startLocationManager]; // ロケーションマネージャ開始
        
    } else {
        
        label_status.text = @"ログインしてください";
        
        AlertViewWithBlock* alert =
        [[AlertViewWithBlock alloc]
         initWithTitle:@"ログインしてください"
         message:@"設定画面からログインしてください。"
         cancelHandler:^(UIAlertView* alertView){
             
         } buttonHandler:^(UIAlertView* alertView, NSInteger buttonIndex){
             
             UITabBarController *controller = self.tabBarController;
             controller.selectedViewController = [controller.viewControllers objectAtIndex:1];
             
         } buttonTitles:@"設定画面へ", nil];
        
        [alert show];
        
    }
    
    // fpsの処理(別スレッド)
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue(); // メインスレッド
    dispatch_async(globalQueue, ^{
        
        int framecount = 0;
        clock_t time_before = clock();
        clock_t time_current;
        double average;
        
        while (YES) {
            
            time_current = clock();
            
            average += (framecount%SAMPLING) / difftime(time_current, time_before);
            
            // フレーム数がサンプリング数値に達した場合
            if (framecount%SAMPLING == (SAMPLING - 1)) {
                
                average /= SAMPLING;
                
                // fpsをメインスレッドへ書き出し
                dispatch_sync(mainQueue, ^{
                    
                    fps = average;
                    
                    if (isnan(fps) || isinf(fps)) {
                        
                        label_fps.text = @"";
                        
                    } else {
                        
                        label_fps.text = [NSString stringWithFormat:@"%.1ffps", average];
                        
                    }
                    
                });
                
                average = 0;
                
            }
            
            time_before = time_current;
            framecount++;
            
        }
        
    });
    
#if TARGET_IPHONE_SIMULATOR
    // シミュレーター上でのみ実行される処理
    // カメラプレビューの部分は真っ白に塗りつぶしておく
    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.view.backgroundColor=color;
    
#else
    // 実機でのみ実行される処理
    
    @try {
        
        /* _/_/_/_/_/_/_/_/_/_/
         * カメラプレビュー関連
         * _/_/_/_/_/_/_/_/_/_/ */
        
        // 入力と出力からキャプチャーセッションを作成
        self.session = [[AVCaptureSession alloc] init];
        
        // 正面に配置されているカメラを取得
        AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // カメラからの入力を作成し、セッションに追加
        self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:NULL];
        [self.session addInput:self.videoInput];
        
        // 画像への出力を作成し、セッションに追加
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [self.session addOutput:self.stillImageOutput];
        
        // キャプチャーセッションから入力のプレビュー表示を作成
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        captureVideoPreviewLayer.frame = self.view.bounds;
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        // レイヤーをViewの最背面に設定
        CALayer *previewLayer = self.previewView.layer;
        previewLayer.masksToBounds = YES;
        [previewLayer addSublayer:captureVideoPreviewLayer];
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"%@",exception);
        
        // カメラプレビューの部分は真っ白に塗りつぶしておく
        UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        self.view.backgroundColor=color;
        
    }
    
#endif
    
}

- (void) calcFPS
{
    
    if (!flag) {
        elapsedTimeList = [NSMutableArray arrayWithCapacity:SAMPLING];
        for (int i=0; i < SAMPLING; i++) {
            [elapsedTimeList addObject:[NSNull null]];
        }
        flag = YES;
    }
    
    while (YES) {
        
        // 経過時間
        elapsedTime = currentTime - previewTime;
        previewTime = currentTime; // メインスレッドで取得した時間を、前の時間として格納
        
        times += elapsedTime; // 最新の経過時間を、経過時間の和に加算する
        [elapsedTimeList insertObject:[[NSNumber alloc] initWithLongLong:elapsedTime] atIndex:(count%SAMPLING)];
        
        if ((count%SAMPLING) == (SAMPLING - 1)) { // カウント数の余りがサンプリング数値に達したら
            
            times -= [[elapsedTimeList objectAtIndex:0] intValue];
            
        } else if (![[elapsedTimeList objectAtIndex:((count%SAMPLING) + 1)] isEqual:[NSNull null]]) {
            
            times -= [[elapsedTimeList objectAtIndex:((count%SAMPLING) + 1)] intValue];
            
        }
        
        if (times == 0) { // 0除算を避ける為分岐
            
            fps = 0.0f;
            
        } else {
            
            fps = (SAMPLING * 1000.0f) / times; // fps
            
        }
        
    }
}

// ビューが破棄されたとき(onDestroy)
- (void)viewDidUnload
{
    
    [self setLabel_status:nil];
    [self setLabel_fps:nil];
    [self setLabel_latitude:nil];
    [self setLabel_longitude:nil];
    [self setImage_found:nil];
    [super viewDidUnload];
    
    // GPSを切断する
    [self stopLocationManager];
    
}

// ビューが再度現れようとしているとき
- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
}

// ビューが再度現れたとき(タブ切り替え時など)
- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    if (!isViewAppeared) {
        isViewAppeared = YES;
        return;
    }
    
    // とりあえず発見画像は隠す
    image_found.hidden = YES;
    
    // ユーザー情報を再取得(ユーザーが変わっている可能性があるため)
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    userName = [defaults objectForKey:@"userName"];
    loginHash = [defaults objectForKey:@"loginHash"];
    
    NSLog(@"userName:%@, loginHash:%@", userName, loginHash);
    
    if (userName == nil || loginHash == nil) {
        
        NSLog(@"reached isLogined=NO of viewDidAppear");
        isLogined = NO;
        
    } else {
        
        isLogined = YES;
        
    }
    NSLog(@"isLogined=%@", (isLogined ? @"YES" : @"NO"));
    
    // ログイン状態によってメッセージ表示を切り分ける
    if (isLogined) {
        
        // 再度目標地点情報を取得して反映
        targetName = [defaults objectForKey:@"pointName"];
        targetLatitude = [defaults doubleForKey:@"pointLatitude"];
        targetLongitude = [defaults doubleForKey:@"pointLongitude"];
        
        label_status.textColor = [UIColor blueColor];
        label_status.text = @"現在地取得中…";
        [self startLocationManager]; // ロケーションマネージャ再開
        
    } else {
        
        label_status.text = @"ログインしてください";
        
        AlertViewWithBlock* alert =
        [[AlertViewWithBlock alloc]
         initWithTitle:@"ログインしてください"
         message:@"設定画面からログインしてください。"
         cancelHandler:^(UIAlertView* alertView){
             
         } buttonHandler:^(UIAlertView* alertView, NSInteger buttonIndex){
             
             UITabBarController *controller = self.tabBarController;
             controller.selectedViewController = [controller.viewControllers objectAtIndex:1];
             
         } buttonTitles:@"設定画面へ", nil];
        
        [alert show];
        
    }
    
}

// 別のビューに移動しようとしているとき
- (void)viewWillDisappear:(BOOL)animated
{
    
	[super viewWillDisappear:animated];
    
    // GPSを一旦切断する
    [self stopLocationManager];
    
}

// 別のビューに移動する寸前
- (void)viewDidDisappear:(BOOL)animated
{
    
	[super viewDidDisappear:animated];
    
}

#pragma mark - Location Manager

// 位置情報関連(ここから)
// CoreLocationのロケマネで位置が取得できたとき(iOS 5用)
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    // 未ログインであれば、ログインを促しロケーションマネージャを切断して終了
    if (!isLogined || userName == nil || loginHash == nil) {
        
        label_status.text = [NSString stringWithFormat:@"ログインしてください"];
        [self stopLocationManager];
        return;
        
    }
    
    // 位置情報を取り出す
    latitude = newLocation.coordinate.latitude; 
    longitude = newLocation.coordinate.longitude;
    // 取得時間を生成
    UInt64 timeStamp = (UInt64)floor(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    
    // 位置情報をサーバーに送信する
    UserPoint *up = [[UserPoint alloc] init];
    NSString *server = [NSString stringWithCString:SERVER encoding:NSUTF8StringEncoding];
    
    [up setUserPoint:server userName:userName latitude:latitude longitude:longitude timeStamp:timeStamp hashClient:loginHash];
    
    label_latitude.text = [NSString stringWithFormat:@"緯度=%f", latitude];
    label_longitude.text = [NSString stringWithFormat:@"経度=%f", longitude];
    
    // 目標地点までの距離を計算
    double dist = [Coords calcDistHubeny:GRS80 latitudeFrom:latitude longitudeFrom:longitude latitudeTo:targetLatitude longitudeTo:targetLongitude];
    NSString *distLabel = [NSString stringWithFormat:@"%.1fm", dist];
    if (dist > 1000.0) {
        
        distLabel = [NSString stringWithFormat:@"%.1fkm", (dist / 1000.0)];
        
    }
    
    if (dist < FOUNDDISTANCE) {
        
        // ラベルに目標地点までの距離を表示
        label_status.textColor = [UIColor redColor];
        label_status.text = [NSString stringWithFormat:@"｢%@｣を発見！(%@)", targetName, distLabel];
        
        // 発見画像を表示
        image_found.hidden = NO;
        
        // twitter投稿画面を表示
        [self tweet:[NSString stringWithFormat:@"｢%@｣を発見！(%@, %.1ffps)", targetName, distLabel, fps]];
        
    } else {
        
        // 発見画像を隠す
        if (image_found.hidden == NO) {
            image_found.hidden = YES;
        }
        
        // ラベルに目標地点までの距離を表示
        label_status.textColor = [UIColor blueColor];
        label_status.text = [NSString stringWithFormat:@"｢%@｣まで%@", targetName, distLabel];
        
    }
    
    // 設定情報を読み書き
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    // 位置情報を取得でき次第、GPSを切断するかどうかの情報
    BOOL one_time = NO; // 初期値はNO
    one_time = [defaults boolForKey:@"one_time"];
    
    // 取得できたらロケマネ終了
    if (one_time) {
        [self stopLocationManager]; // ここで止めるとエラー出るので、別メソッドで停止
    }
    
}

// GPSを使えるようにする
- (void) startLocationManager
{
    
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    
    NSLog(@"Location manager is started.");
    
}

// GPSを止める
- (void) stopLocationManager
{
    
    [locationManager stopUpdatingLocation];
    NSLog(@"Location manager is stopped.");
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"位置情報が取得できませんでした。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    
}
// 位置情報関連(ここまで)

#pragma mark - Twitter

- (void) tweet:(NSString*)message
{
    
    // twitterのアカウントを取得
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [store requestAccessToAccountsWithType:twitterType
                     withCompletionHandler:^(BOOL granted, NSError *error) {
        
        // アクセス許可時の処理
        if (granted) {
            self.twitterAccounts = [store accountsWithAccountType:twitterType]; 
            
            if ([twitterAccounts count] == 0) {
                
                AlertViewWithBlock* alert = 
                    [[AlertViewWithBlock alloc]
                        initWithTitle:@"タイトル"
                        message:@"設定画面より、twitterのアカウントを設定してください。"
                        cancelHandler:^(UIAlertView* alertView){
                            
                        } buttonHandler:^(UIAlertView* alertView, NSInteger buttonIndex){
                            
                            if (buttonIndex == 1) {
                                
                                NSLog(@"pushed OK.");
                                
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];       
                                
                            } else {
                                
                                NSLog(@"pushed cancel.");
                            }
                        
                        } buttonTitles:@"キャンセル", @"設定画面へ", nil];
                
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                return;
            
            } else {
                
                tweetMessage = [[NSString alloc] initWithString:message];
                
                AlertViewWithBlock* alert = 
                    [[AlertViewWithBlock alloc]
                        initWithTitle:@"タイトル"
                        message:@"twitterに地点発見時の情報を投稿しますか?"
                        cancelHandler:^(UIAlertView* alertView){
                        
                        } buttonHandler:^(UIAlertView* alertView, NSInteger buttonIndex){
                            
                            if (buttonIndex == 1) {
                                
                                NSLog(@"pushed OK.");
                                
                                [self post];
                            
                            } else {
                                
                                NSLog(@"pushed cancel.");
                            
                            }
                        
                        } buttonTitles:@"キャンセル",@"OK", nil];
                
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            
            }
        
        } else {
            
            UIAlertView *alertView = 
            [[UIAlertView alloc]initWithTitle:@"エラー"
                                      message:@"twitterでつぶやくには、twitterへのアクセスを許可してください。"
                                     delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            return;
            
        }
        
    }];

}

- (void) post
{
    
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    [tweetSheet setInitialText:tweetMessage];
    [self presentModalViewController:tweetSheet animated:YES];
    
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) {
        
        switch (result)
        {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case TWTweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: done");
                [self doneTweet];
                break;
            default:
                NSLog(@"Twitter Result: processed");
                break;
        }
        
        [self dismissModalViewControllerAnimated:YES];
    };
    
}

- (void) doneTweet
{
    
    UIAlertView *alertView = 
    [[UIAlertView alloc]initWithTitle:@"投稿完了"
                              message:@"twitterにつぶやきました。"
                             delegate:nil
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
}

#pragma mark - Display Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return NO;
    }
    
}

@end
