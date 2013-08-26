//
//  UserPoint.h
//  pointdetector
//
//  Created by  on 13/08/08.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

#define HTTP_TIMEOUT 30

@interface UserPoint : NSObject {
    id connection;
    NSMutableData *receivedData;
    Message *message;
    BOOL sending;
}

@property (nonatomic, strong) id connection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) Message *message;
@property (nonatomic) BOOL sending;

- (void) setUserPoint:(NSString *)url userName:(NSString *)userName
             latitude:(double)latitude longitude:(double)longitude
            timeStamp:(UInt64)timeStamp hashClient:(NSString *)hashClient;

- (void) userPointsSuccessSetting;
- (void) userPointsFailure;

@end
