//
//  FirstViewController.h
//  pointdetector
//
//  Created by  on 13/08/02.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <MapKit/MapKit.h>
#import <time.h>
#import "TargetConditionals.h"
#import "AlertViewWithBlock.h"
#import "Coords.h"
#import "UserPoint.h"

#define SERVER "http://www15052ui.sakura.ne.jp/"
#define SAMPLING 5 // フレームレートのサンプリング数値
#define FOUNDDISTANCE 10.0 // 発見したことを通知する距離

@interface FirstViewController : UIViewController <CLLocationManagerDelegate> {
    
    UIView *uiView;
    CLLocationManager *locationManager;
    
    BOOL isViewAppeared;
    
    double fps;
    UInt64 count, times, previewTime, currentTime, elapsedTime;
    BOOL flag;
    NSMutableArray *elapsedTimeList;
    
    NSArray *twitterAccounts;
    NSString *tweetMessage;
    
    NSString *userName, *loginHash;
    BOOL isLogined;
    
    double latitude, longitude;
    NSString *targetName;
    double targetLatitude, targetLongitude;
    
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *label_status;
@property (weak, nonatomic) IBOutlet UILabel *label_fps;
@property (weak, nonatomic) IBOutlet UILabel *label_latitude;
@property (weak, nonatomic) IBOutlet UILabel *label_longitude;
@property (weak, nonatomic) IBOutlet UIImageView *image_found;

@property (nonatomic) BOOL isViewAppeared;

@property (nonatomic) double fps;
@property (nonatomic) UInt64 count;
@property (nonatomic) UInt64 times;
@property (nonatomic) BOOL flag;
@property (nonatomic) UInt64 previewTime;
@property (nonatomic) UInt64 currentTime;
@property (nonatomic) UInt64 elapsedTime;
@property (nonatomic, copy) NSMutableArray *elapsedTimeList;

@property (nonatomic, strong) NSArray *twitterAccounts;
@property (nonatomic, copy) NSString *tweetMessage;

@property (nonatomic, strong) AVCaptureSession* captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput* imageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic) BOOL adjustingExposure;

- (void) startLocationManager;
- (void) stopLocationManager;

- (void) calcFPS;

- (void) tweet:(NSString*)message;
- (void) post;
- (void) doneTweet;

@end
