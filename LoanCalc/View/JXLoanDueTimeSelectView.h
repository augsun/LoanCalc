//
//  JXLoanDueTimeSelectView.h
//  LoanCalc
//
//  Created by augsun on 3/5/17.
//  Copyright © 2017 sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXLoanDueTimeSelectView : UIView

- (void)showWithOK:(void(^)(NSInteger years, NSInteger months))ok;

@end
