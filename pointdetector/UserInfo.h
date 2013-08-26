//
//  UserInfo.h
//  pointdetector
//
//  Created by  on 13/08/06.
//  Copyright (c) 2013 Sasaki Ryuta. All rights reserved.
//

#import "Message.h"

@interface UserInfo : Message {
    
    NSInteger user_id;
    NSInteger set_point;
    NSString *login_hash;
    
}

@property (nonatomic) NSInteger user_id;
@property (nonatomic) NSInteger set_point;
@property (nonatomic, copy) NSString *login_hash;

@end
