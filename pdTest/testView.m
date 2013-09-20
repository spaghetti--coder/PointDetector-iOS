//
//  testView.m
//  pointdetector
//
//  Created by 佐々木　竜太 on 2013/09/20.
//
//

#import "testView.h"

@implementation testView

- (void)testView
{
    UIView *view = [[UIView alloc] init];
    view.frame = [UIScreen mainScreen].bounds;
    GHVerifyView(view);
    
    
    
}

@end
