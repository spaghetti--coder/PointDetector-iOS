//
//  SecondViewController.m
//  pointdetector
//
//  Created by  on 13/08/02.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import "SecondViewController.h"

@implementation SecondViewController
@synthesize edittext_username;
@synthesize edittext_username_ipad;
@synthesize edittext_password;
@synthesize edittext_password_ipad;
@synthesize button_login;
@synthesize button_newaccount;
@synthesize label_loginstatus;
@synthesize button_selecttarget;
@synthesize label_targetstatus;
@synthesize switch_gps;

@synthesize isFirstLogin;
@synthesize rollShow;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFirstLogin = NO;
    resetCount = 0;
    rollShow = NO;
    
    // iPhone or iPodの場合
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        // ユーザー名とパスワード欄をdelegateする
        edittext_username.delegate = self;
        edittext_password.delegate = self;
        
    // iPadの場合
    } else {
        
        // レイアウトの関係でTextViewを用いている為、角丸にする
        edittext_username_ipad.layer.borderWidth = 1.0f;
        edittext_username_ipad.layer.cornerRadius = 10.0f;
        edittext_username_ipad.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        edittext_password_ipad.layer.borderWidth = 1.0f;
        edittext_password_ipad.layer.cornerRadius = 10.0f;
        edittext_password_ipad.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        // ユーザー名とパスワード欄をdelegateする
        edittext_username_ipad.delegate = (id)self;
        edittext_password_ipad.delegate = (id)self;
        
    }
    
    // ログイン・目標地点ステータスのラベルを空文字にする
    label_loginstatus.text = [NSString stringWithFormat:@""];
    label_targetstatus.text = [NSString stringWithFormat:@""];
    
    // 設定を読み出し、設定変更する
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userName = [defaults objectForKey:@"userName"];
    NSString *loginHash = [defaults objectForKey:@"loginHash"];
    NSLog(@"[%@/%@]", userName, loginHash);
    
    if (userName == nil || loginHash == nil) { // nilであれば、メモリアクセス前にこのメソッドを抜ける
        
        isFirstLogin = YES;
        return;
        
    }
    
    if (![userName isEqualToString:@""] && ![loginHash isEqualToString:@""]) {
        
        // 地点情報取得
        TargetPoint *tp = [[TargetPoint alloc] init];
        [tp targetpoints:@"http://www15052ui.sakura.ne.jp/" flag:NO];
        
        // ログイン中のユーザー名を、ユーザー名のフィールドに反映させる
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            edittext_username.text = userName;
            
        } else {
            
            edittext_username_ipad.text = userName;
            
        }
        
    }
    
    NSLog(@"one_time:%d", [defaults boolForKey:@"one_time"]);
    if ([defaults boolForKey:@"one_time"]) {
        switch_gps.on = YES;
        NSLog(@"switch_gps has turned on.");
    } else {
        switch_gps.on = NO;
        NSLog(@"switch_gps has turned off.");
    }
    
}

- (void)viewDidUnload
{
    [self setEdittext_username:nil];
    [self setEdittext_password:nil];
    [self setButton_login:nil];
    [self setButton_newaccount:nil];
    [self setLabel_loginstatus:nil];
    [self setButton_selecttarget:nil];
    [self setLabel_targetstatus:nil];
    [self setSwitch_gps:nil];
    [self setEdittext_username_ipad:nil];
    [self setEdittext_password_ipad:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.view removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    resetCount = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [defaults objectForKey:@"userName"];
    
    if (userName != nil) {
        
        // ログイン中のユーザー名の文字列を復活
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            edittext_username.text = userName;
            
        } else {
            
            edittext_username_ipad.text = userName;
            
        }
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    targetPicker.hidden = YES;
    [self.view sendSubviewToBack:targetPicker];
    
    // ユーザー名とパスワードの文字列は削除しておく
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        edittext_username.text = @"";
        edittext_password.text = @"";
        
    } else {
        
        edittext_username_ipad.text = @"";
        edittext_password_ipad.text = @"";
        
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    
    if (textField == edittext_username) {
        [edittext_username resignFirstResponder]; // ユーザー名のキーボードを隠す
        [edittext_password becomeFirstResponder]; // パスワードにフォーカスを当てる
    } else if (textField == edittext_password) {
        [edittext_password resignFirstResponder]; // パスワードからフォーカスを外す
        [self login]; // ログイン処理を行う(ログインボタンを押したときと同じ動作)
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    // パスワード文字列の初期化
    if (passwordBuffer == nil) {
        passwordBuffer = [NSMutableString stringWithCapacity: 0];
    }
    if (passwordMask == nil) {
        passwordMask = [NSMutableString stringWithCapacity: 0];
    }
    
    // 改行コードまたはタブが入力された場合
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@"\t"]) {
        
        if (textView == edittext_username_ipad) {
            
            [edittext_username_ipad resignFirstResponder];
            [edittext_password_ipad becomeFirstResponder];
            
        } else if (textView == edittext_password_ipad) {
            
            [edittext_password_ipad resignFirstResponder];
            [self login]; // ログイン処理を行う(ログインボタンを押したときと同じ動作)
            
        } else {
        
            [textView resignFirstResponder];
            
        }
        
        // 改行コードorタブは入力させない
        return NO;
        
    // パスワード入力時は、前の文字を●にして入力文字列をバッファリング
    // (実装割愛)
    } else if (textView == edittext_password_ipad) {
        
//        [passwordBuffer appendString:text];
//        [passwordMask appendString:text];
//        
//        if ([text isEqualToString:@"\b"]) {
//            
//            NSLog(@"pressed backspace key.");
//            [passwordBuffer deleteCharactersInRange:NSMakeRange(2, 1)];
//            edittext_password_ipad.text = passwordMask;
//            
//        } else {
//            
//            if ([passwordBuffer length] != 1) {
//                
//                [passwordMask replaceCharactersInRange:NSMakeRange(
//                    0, [passwordMask length] -1) withString:@"*"];
//                edittext_password_ipad.text = passwordMask;
//                
//            }
//            
//        }
        
    }
    
    // それ以外の文字コードは通す
    return YES;
    
}

// 「ログイン」ボタンがタップされたとき
- (IBAction)button_login_touched:(id)sender
{
    
    // ログイン処理を行うメソッドを呼び出す
    [self login];
    
}

- (void) login
{
    
    // ログインURL
    NSURL *loginUrl = [NSURL URLWithString:[NSString stringWithCString:SERVER_LOGIN encoding:NSUTF8StringEncoding]];
    
    // POSTする項目を設定
    NSString *username;
    NSString *password;
    
    // iPhone or iPodの場合
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        username = edittext_username.text;
        password = edittext_password.text;
        
    // iPadの場合
    } else {
        
        username = edittext_username_ipad.text;
        password = edittext_password_ipad.text;
        
    }
    
    NSDictionary *loginParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 username, @"username",
                                 password, @"password", nil];
    
    // POSTする
    LoginAuth *lauth = [[LoginAuth alloc] init];
    [lauth post:loginUrl withParameters:(NSDictionary *)loginParams flag:isFirstLogin];
    
}

// 「新規アカウント作成」ボタンがタップされたとき
- (IBAction)button_newaccount_touched:(id)sender
{
    
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:@"http://www15052ui.sakura.ne.jp/apply/"]];
    
}

// 「地点選択」ボタンがタップされたとき
- (IBAction)button_selecttarget_touched:(id)sender
{
    
    if (resetCount == 6) {
        
        [self resetPreferences];
        return;
        
    }
    
    if (rollShow && targetPicker != nil) {
        
        targetPicker.hidden = YES;
        rollShow = NO;
        return;
        
    } else {
        
        if (targetPicker != nil) {
            targetPicker.hidden = NO;
        }
        rollShow = YES;
        
    }
    
    // 先に地点情報を読み出し、イニシャライズ
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // ピッカーがまだ用意されていなければ、イニシャライズする
    if (targetPicker == nil) {
        // 地点情報
        targetPoints = [defaults objectForKey:@"targetPoints"];
        
        // 地点情報がなければ、そこで終了
        if (targetPoints == nil) {
            
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"目標地点一覧"
                                      message:@"ログインして、目標地点一覧を取得してください。"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
            
        }
        
        // ピッカー自体のイニシャライズ
        targetPicker = [[UIPickerView alloc] init];
        targetPicker.center = self.view.center;  // 中央に表示
        targetPicker.delegate = self;  // デリゲートを自分自身に設定
        targetPicker.dataSource = self;  // データソースを自分自身に設定
        targetPicker.showsSelectionIndicator = YES; // インジケーターを使うかどうか
        
        int pointID = [defaults integerForKey:@"pointID"];
        
        if (pointID > 0) {
            [targetPicker selectRow:(pointID - 1) inComponent:0 animated:YES];
        }
        
//        CGAffineTransform t0 = CGAffineTransformMakeTranslation(targetPicker.bounds.size.width/2, targetPicker.bounds.size.height/2);
//        CGAffineTransform s0 = CGAffineTransformMakeScale(0.5, 0.5);
//        CGAffineTransform t1 = CGAffineTransformMakeTranslation(-targetPicker.bounds.size.width/2, -targetPicker.bounds.size.height/2);
//        targetPicker.transform = CGAffineTransformConcat(t0, CGAffineTransformConcat(s0, t1));
        
        [self.view addSubview:targetPicker];
        
    // 既に用意されているのであれば、再び前面に表示する 
    } else {
        
        [self.view bringSubviewToFront:targetPicker];
        targetPicker.hidden = NO;
        int pointID = [defaults integerForKey:@"pointID"];
        
        if (pointID > 0) {
            [targetPicker selectRow:(pointID - 1) inComponent:0 animated:YES];
        }
        
    }
    
}

// 目標地点情報を保存するメソッド
- (void) saveTargetPoint:(int)pointID pointName:(NSString*)pointName
                latitude:(double)latitude lontigude:(double)longitude
{
    
    // 設定情報を参照
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // ユーザー名とログインハッシュを取得
    NSString *userName = [defaults objectForKey:@"userName"];
    NSString *loginHash = [defaults objectForKey:@"loginHash"];
    
    if (userName == nil || loginHash == nil) {
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"未ログイン"
                                  message:@"ログインしてから地点を設定してください。"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil];
        [alertView show];
        
        return;
    }
    
    // 送信サーバを指定
    NSString *url = [NSString stringWithCString:SERVER encoding:(NSUTF8StringEncoding)];
    
    // TargetPointオブジェクトに、サーバーへの処理を投げる(非同期通信を使用する関係上)
    TargetPoint *tp = [[TargetPoint alloc] init];
    [tp setTargetPoint:url userName:userName pointID:pointID hashClient:loginHash];
    
    // アプリの設定情報に保存
    [defaults setInteger:pointID forKey:@"pointID"];
    [defaults setObject:pointName forKey:@"pointName"];
    [defaults setDouble:latitude forKey:@"pointLatitude"];
    [defaults setDouble:longitude forKey:@"pointLongitude"];
    
}

/* ----------------------------------
 * UIPickerViewのデリゲートメソッド(ここから)
 * ---------------------------------- */

// 列数指定
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    
    return 1; // デフォルトの列数は1
    
}

// 行数指定
- (NSInteger)pickerView:(UIPickerView*)pickerView
    numberOfRowsInComponent:(NSInteger)component
{
    
    // 列が複数ある場合は、下記のようにcomponentで指定すること(0からスタート)
//    if(component == 0){
//        return 10;  // 1列目は10行
//    }else{
//        return 5;  // 2列目は5行
//    }
    
    // 目標地点選択の場合(地点の個数を返却すること)
    if (pickerView == targetPicker) {
        return [targetPoints count];
    }
    
    return 10;
    
}

// 表示する内容を返す例
-(NSString*)pickerView:(UIPickerView*)pickerView
    titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    // 全要素を解釈するサンプルコード
//    NSEnumerator* placeEnumerator = [targetPoints objectEnumerator];
//    id places = nil;
//    
//    while (places = [placeEnumerator nextObject]) {
//        
//        //                NSLog(@"places: %@", places);
//        PointDetail *pd = [[PointDetail alloc] init];
//        
//        NSEnumerator* keyEnumerator = [places keyEnumerator];
//        NSEnumerator* objectEnumerator = [places objectEnumerator];
//        id key = nil;
//        id value = nil;
//        
//        while (key = [keyEnumerator nextObject]) {
//            value = [objectEnumerator nextObject];
//            //                    NSLog(@"[key:%@/value:%@]", key, value);
//            
//            if ([key isEqualToString:@"id"]) {
//                pd.pointID = [value intValue];
//            } else if ([key isEqualToString:@"point_name"]) {
//                pd.pointName = value;
//            } else if ([key isEqualToString:@"latitude"]) {
//                pd.latitude = [value doubleValue];
//            } else if ([key isEqualToString:@"longitude"]) {
//                pd.longitude = [value doubleValue];
//            }
//            pd.timeStamp = 0; // timeStamp is none
//            
//        }
//        
//        NSLog(@"[PointDetail] id:%d, name:%@, lat:%f, lon:%f",
//              pd.pointID, pd.pointName, pd.latitude, pd.longitude);
//        [targetPoints addObject:pd];
//        
//    }
    
    // 地点選択
    if (pickerView == targetPicker) {
        
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
            
            if (row == (pd.pointID - 1)) {
                
                return pd.pointName;
                
            }
            
        }
        
    }
    
    // デフォルトでは行インデックス番号を返す
    return [NSString stringWithFormat:@"%d", row];
    
}

// 行が選択されたときの処理
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
//    // 1列目の選択された行数を取得
//    NSInteger val0 = [pickerView selectedRowInComponent:0];
//    
//    NSLog(@"1列目:%d行目が選択[%d行目]", val0, row);
    
    rollShow = NO;
    
    // 取得地点名をアラートで表示
    if (pickerView == targetPicker) {
        
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
            
            if (row == (pd.pointID - 1)) {
                
                // サーバー側に地点情報を送信し、設定マネージャに保存
                [self saveTargetPoint:pd.pointID pointName:pd.pointName
                 latitude:pd.latitude lontigude:pd.longitude];
                
            }
            
        }
        
    }
    
    // ピッカービューを隠し、最背面に配置
    pickerView.hidden = YES;
    [self.view sendSubviewToBack:pickerView];
    
}

/* ----------------------------------
 * UIPickerViewのデリゲートメソッド(ここまで)
 * ---------------------------------- */

// GPSをすぐ終了するかどうかのスイッチがタップされたとき
- (IBAction)switch_gps_changed:(id)sender
{
    
    resetCount++;
    
    // 設定値を保存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (switch_gps.on) { // GPS切断→on
        
        [defaults setBool:YES forKey:@"one_time"];
        
    } else { // GPS切断→off
        
        [defaults setBool:NO forKey:@"one_time"];
        
    }
    
}

- (void) resetPreferences
{
    
    AlertViewWithBlock* alert =
    [[AlertViewWithBlock alloc]
     initWithTitle:@"ユーザー設定のリセット"
     message:@"アプリ内の設定情報を消去しますか?\(元に戻せません)"
     cancelHandler:^(UIAlertView* alertView){
         
     } buttonHandler:^(UIAlertView* alertView, NSInteger buttonIndex){
         
         if (buttonIndex == 1) {
             
             NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
             [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
             
             [self preferencesDeleted];
             
         }
         
     } buttonTitles:@"キャンセル", @"消去", nil];
    
    [alert show];
    
}

- (void) preferencesDeleted
{
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"消去完了"
                              message:@"アプリ内の設定情報を消去しました。"
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
    [alertView show];
    
}

@end
