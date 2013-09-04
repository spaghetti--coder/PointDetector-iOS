//
//  pointdetectorTests.m
//  pointdetectorTests
//
//  Created by  on 13/08/02.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "pointdetectorTests.h"

@implementation pointdetectorTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    test_subject = [[TargetPoint alloc] init]; // not write retain because using ARC
    defaults = [NSUserDefaults standardUserDefaults];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testNSUserDefaults
{
    
    float targetLat = [defaults floatForKey:@"pointLatitude"];
    float targetLng = [defaults floatForKey:@"pointLongitude"];
    
    if (!targetLat) {
        STFail(@"目標地点の緯度が未保存");
    }
    if (!targetLng) {
        STFail(@"目標地点の経度が未保存");
    }
    
    if (targetLat == targetLng) {
        STFail(@"緯度と経度が同じ値");
    }
    
}

@end
