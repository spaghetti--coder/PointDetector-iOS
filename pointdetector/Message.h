//
//  Message.h
//  pointdetector
//
//  Created by  on 13/08/06.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject {
    
    BOOL result;
    NSString *message;
    
}
@property (nonatomic) BOOL result;
@property (nonatomic, copy) NSString *message;

@end
