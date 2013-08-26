//
//  MyAlertView.m
//  pointdetector
//
//  Created by  on 13/08/08.
//  cf. )http://sos.hatenablog.jp/entry/2013/01/28/051727
//

#import "AlertViewWithBlock.h"

@implementation AlertViewWithBlock
{
    void (^varbuttonHandler)(UIAlertView*, NSInteger);
    void (^varcancelHandler)(UIAlertView*);
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelHandler:(void (^)(UIAlertView*))cancelHandler buttonHandler:(void (^)(UIAlertView*, NSInteger))buttonHandler buttonTitles:(NSString *)buttonTitles, ...
{
    self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    if(self){
        va_list argumentList;
        if(buttonTitles){
            [self addButtonWithTitle:buttonTitles];
            va_start(argumentList, buttonTitles);
            id eachObj;
            while ((eachObj = va_arg(argumentList, id))){
                [self addButtonWithTitle: eachObj];
            }
            va_end(argumentList);
        }
        varcancelHandler = cancelHandler;
        varbuttonHandler = buttonHandler;
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(varbuttonHandler){
        varbuttonHandler(alertView,buttonIndex);
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView{
    if(varcancelHandler){
        varcancelHandler(alertView);
    }
}

@end
