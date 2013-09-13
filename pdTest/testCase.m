//
//  testCase.m
//  pointdetector
//
//  Created by 佐々木　竜太 on 2013/09/13.
//
//

#import "testCase.h"

@implementation testCase

- (void)test_sample
{
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"SAMPLE"] uppercaseString];
    GHAssertEqualStrings(@"SAMPLE", [mock uppercaseString], @"match");
}

@end
