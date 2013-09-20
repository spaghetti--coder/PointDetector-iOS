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

- (void) testLoginForm
{
    
//    id mock = [OCMockObject mockForClass:[SecondViewController class]];
    
    
}

@end
