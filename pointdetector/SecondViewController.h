//
//  SecondViewController.h
//  pointdetector
//
//  Created by  on 13/08/02.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TargetConditionals.h"
#import "UserInfo.h"
#import "LoginAuth.h"
#import "AlertViewWithBlock.h"

#define SERVER "http://www15052ui.sakura.ne.jp/"
#define SERVER_LOGIN "http://www15052ui.sakura.ne.jp/appli/login"
#define HTTP_TIMEOUT 30

@interface SecondViewController : UIViewController <UIAlertViewDelegate, 
    UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
        NSMutableString *passwordBuffer;
        NSMutableString *passwordMask;
        UIPickerView *targetPicker;
        NSMutableArray *targetPoints;
        BOOL isFirstLogin;
        BOOL rollShow;
        int resetCount;
}
@property (weak, nonatomic) IBOutlet UITextField *edittext_username;
@property (weak, nonatomic) IBOutlet UITextView *edittext_username_ipad;
@property (weak, nonatomic) IBOutlet UITextField *edittext_password;
@property (weak, nonatomic) IBOutlet UITextView *edittext_password_ipad;
@property (weak, nonatomic) IBOutlet UIButton *button_login;
- (IBAction) button_login_touched:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button_newaccount;
- (IBAction) button_newaccount_touched:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label_loginstatus;
@property (weak, nonatomic) IBOutlet UIButton *button_selecttarget;
- (IBAction) button_selecttarget_touched:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label_targetstatus;
@property (weak, nonatomic) IBOutlet UISwitch *switch_gps;
- (IBAction) switch_gps_changed:(id)sender;

@property (nonatomic) BOOL isFirstLogin;
@property (nonatomic) BOOL rollShow;

- (void) login;
- (void) saveTargetPoint:(int)pointID pointName:(NSString*)pointName
                latitude:(double)latitude lontigude:(double)longitude;
- (void) resetPreferences;
- (void) preferencesDeleted;

@end
