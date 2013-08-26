//
//  MyAlertView.h
//  pointdetector
//
//  Created by  on 13/08/08.
//  cf. )http://sos.hatenablog.jp/entry/2013/01/28/051727
//

#import <Foundation/Foundation.h>

@interface AlertViewWithBlock : UIAlertView <UIAlertViewDelegate>

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelHandler:(void (^)(UIAlertView* view))cancelHandler buttonHandler:(void (^)(UIAlertView* view, NSInteger index))buttonHandler buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
