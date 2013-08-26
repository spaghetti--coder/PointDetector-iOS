//
//  PointDetail.h
//  pointdetector
//
//  Created by  on 13/08/07.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PointDetail : NSObject

@property (nonatomic) int pointID;
@property (nonatomic, strong) NSString *pointName;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int timeStamp;

@end
