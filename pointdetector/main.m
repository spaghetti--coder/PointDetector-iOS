//
//  main.m
//  pointdetector
//
//  Created by  on 13/08/02.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        @try {
            
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
            
        } @catch (NSException *exception) {
            
            NSLog(@"%@",exception);
            
        }
    }
}
