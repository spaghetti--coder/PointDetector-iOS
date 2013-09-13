// main.m
#import <UIKit/UIKit.h>
#import "GHUnitIOS/GHUnit.h"

@interface MyUIApp : UIApplication
@end

@implementation MyUIApp

- (id)init
{
    self = [super init];
    if (self && getenv("GHUNIT_CLI") && [[[UIDevice currentDevice] systemVersion] doubleValue] >= 6.0) {
        __block BOOL done = NO;
        NSOperationQueue * queue = [[ NSOperationQueue alloc ] init ];
        [queue addOperationWithBlock:^{
            int status = [GHTestRunner run];
            if (status != 0) {
                NSString *reason = [NSString stringWithFormat:@"failed to test %d", status];
                @throw [NSException exceptionWithName:@"TestFailure" reason:reason userInfo:nil];
            }
            done = YES;
        }];
        
        while( !done ) {
            [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 5] ];
        }
    }
    
    return self;
}

@end

int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, @"MyUIApp", @"GHUnitIPhoneAppDelegate");
    }
}
