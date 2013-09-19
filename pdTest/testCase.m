//
//  testCase.m
//  pointdetector
//
//  Created by 佐々木　竜太 on 2013/09/13.
//
//

#import "testCase.h"
#import "Coords.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "LoginAuth.h"
#import "Message.h"
#import "AlertViewWithBlock.h"
#import "TargetPoint.h"
#import "PointDetail.h"
#import "UserInfo.h"
#import "UserPoint.h"

@implementation testCase

- (void)test_sample
{
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"SAMPLE"] uppercaseString];
    GHAssertEqualStrings(@"SAMPLE", [mock uppercaseString], @"match");
}

//- (void) testLoginForm
//{
//    // モックを作成
//    id mock = [OCMockObject mockForClass:LoginAuth.class];
//    
//    NSURL *loginUrl = [NSURL URLWithString:[NSString stringWithCString:SERVER_LOGIN encoding:NSUTF8StringEncoding]];
//    
//    // ユーザーとパスワードを設定
//    NSString *username = @"";
//    NSString *password = @"";
//    NSDictionary *loginParams = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 username, @"username",
//                                 password, @"password", nil];
//    
//    [[mock stub] post:loginUrl withParameters:loginParams flag:false];
//    
//}

@end
