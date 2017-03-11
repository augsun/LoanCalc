//
//  JXLoanModel.h
//  LoanCalc
//
//  Created by augsun on 3/5/17.
//  Copyright © 2017 sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JXLoanBaseModel : NSObject

- (NSString *)decimalStyle:(CGFloat)num;

@end

@interface JXLoanEveryMonthPayModel : JXLoanBaseModel

@property (nonatomic, assign) NSInteger monthIndex;
@property (nonatomic, assign) CGFloat monthlyPaymentInterest;
@property (nonatomic, assign) CGFloat monthlyPaymentPrinciple;
@property (nonatomic, assign) CGFloat monthlyTotalPay;
@property (nonatomic, assign) CGFloat remain;

//
@property (nonatomic, copy) NSString *monthIndexString;
@property (nonatomic, copy) NSString *monthlyPaymentInterestString;
@property (nonatomic, copy) NSString *monthlyPaymentPrincipleString;
@property (nonatomic, copy) NSString *monthlyTotalPayString;
@property (nonatomic, copy) NSString *remainString;

@end

typedef NS_ENUM(NSUInteger, JXLoanType) {
    JXLoanTypeFixedPayment = 1,
    JXLoanTypeFixedBasis,
};

@interface JXLoanModel : JXLoanBaseModel

@property (nonatomic, assign) JXLoanType loanType;
@property (nonatomic, assign) NSInteger loanMonths;
@property (nonatomic, assign) CGFloat totalLoan;
@property (nonatomic, assign) CGFloat totalInterest;
@property (nonatomic, assign) CGFloat totalPayment;

@property (nonatomic, copy) NSString *loanMonthsString;
@property (nonatomic, copy) NSString *totalLoanString;
@property (nonatomic, copy) NSString *totalInterestString;
@property (nonatomic, copy) NSString *totalPaymentString;
@property (nonatomic, copy) NSArray <JXLoanEveryMonthPayModel *> *everyMonthPayModels;

// amount(10k)
// dueTime(month)
// interestRate(%)
+ (JXLoanModel *)calcWithType:(JXLoanType)type amount:(CGFloat)amount dueTime:(NSInteger)dueTime interestRate:(CGFloat)interestRate;

@end











