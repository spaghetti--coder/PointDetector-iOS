//
//  TargetPoint.h
//  pointdetector
//
//  Created by  on 13/08/07.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
#import "PointDetail.h"

#define HTTP_TIMEOUT 30

#define TP_NONE 0
#define TP_GETTER 1
#define TP_SETTER 2

@interface TargetPoint : NSObject {
    id connection;
    NSMutableData *receivedData;
    NSMutableArray *targetPoints;
    int mode;
    Message *message;
    BOOL isFirstLogin;
}

@property (nonatomic, strong) id connection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSMutableArray *targetPoints;
@property (nonatomic, strong) Message *message;
@property (nonatomic) BOOL isFirstLogin;

// 目標地点取得部(GETTER/サーバー→アプリに目標地点一覧を保存)
- (void) targetpoints:(NSString *)url flag:(BOOL)flag;
//　目標地点設定部(SETTER/アプリ→サーバーに目標地点送信)
- (void) setTargetPoint:(NSString *)url userName:(NSString *)userName
                pointID:(int)pointID hashClient:(NSString *)hashClient;

- (void) targetPointsSuccessGetting;
- (void) targetPointsSuccessSetting;
- (void) targetPointsFailure;

@end
