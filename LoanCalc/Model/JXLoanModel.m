//
//  JXLoanModel.m
//  LoanCalc
//
//  Created by augsun on 3/5/17.
//  Copyright © 2017 sun. All rights reserved.
//

#import "JXLoanModel.h"

@implementation JXLoanBaseModel

- (NSString *)decimalStyle:(CGFloat)num {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 2;
    formatter.minimumFractionDigits = 2;
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    return [formatter stringFromNumber:@(num)];
}

@end

@implementation JXLoanEveryMonthPayModel

- (void)setMonthIndex:(NSInteger)monthIndex {
    _monthIndex = monthIndex;
    _monthIndexString = [NSString stringWithFormat:@"%ldth", monthIndex];
}

- (void)setMonthlyPaymentInterest:(CGFloat)monthlyPaymentInterest {
    _monthlyPaymentInterest = monthlyPaymentInterest;
    _monthlyPaymentInterestString = [self decimalStyle:monthlyPaymentInterest];
}

- (void)setMonthlyPaymentPrinciple:(CGFloat)monthlyPaymentPrinciple {
    _monthlyPaymentPrinciple = monthlyPaymentPrinciple;
    _monthlyPaymentPrincipleString = [self decimalStyle:monthlyPaymentPrinciple];
}

- (void)setMonthlyTotalPay:(CGFloat)monthlyTotalPay {
    _monthlyTotalPay = monthlyTotalPay;
    _monthlyTotalPayString = [self decimalStyle:monthlyTotalPay];
}

- (void)setRemain:(CGFloat)remain {
    _remain = remain;
    _remainString = [self decimalStyle:remain];
}

@end

@implementation JXLoanModel

- (void)setLoanMonths:(NSInteger)loanMonths {
    _loanMonths = loanMonths;
    _loanMonthsString = [NSString stringWithFormat:@"%ld", loanMonths];
}

- (void)setTotalLoan:(CGFloat)totalLoan {
    _totalLoan = totalLoan;
    _totalLoanString = [self decimalStyle:totalLoan];
}

- (void)setTotalInterest:(CGFloat)totalInterest {
    _totalInterest = totalInterest;
    _totalInterestString = [self decimalStyle:totalInterest];
}

- (void)setTotalPayment:(CGFloat)totalPayment {
    _totalPayment = totalPayment;
    _totalPaymentString = [self decimalStyle:totalPayment];
}

+ (JXLoanModel *)calcWithType:(JXLoanType)type amount:(CGFloat)amount dueTime:(NSInteger)dueTime interestRate:(CGFloat)interestRate {
    switch (type) {
        case JXLoanTypeFixedPayment:
        {
            return [self calcFixedPaymentWithAmount:amount dueTime:dueTime interestRate:interestRate];
        } break;
            
        case JXLoanTypeFixedBasis:
        {
            return [self calcFixedBasisWithAmount:amount dueTime:dueTime interestRate:interestRate];
        } break;
            
        default:
        {
            return nil;
        } break;
    }
}

+ (JXLoanModel *)calcFixedPaymentWithAmount:(CGFloat)amount dueTime:(NSInteger)dueTime interestRate:(CGFloat)interestRate {
    CGFloat totalLoan = amount * 10000;
    NSInteger loanMonths = dueTime;
    CGFloat monthlyRate = interestRate / 12.f / 100.f;
    CGFloat pow0 = pow(1 + monthlyRate, loanMonths);
    CGFloat denominator = pow0 - 1;
    CGFloat monthlyTotalPay = (totalLoan * monthlyRate * pow(1 + monthlyRate, loanMonths)) / denominator;
    CGFloat totalPayment = monthlyTotalPay * loanMonths;
    CGFloat totalInterest = totalPayment - totalLoan;
    
    //
    JXLoanModel *loanModel = [[JXLoanModel alloc] init];
    loanModel.loanType = JXLoanTypeFixedPayment;
    loanModel.totalLoan = totalLoan;
    loanModel.loanMonths = loanMonths;
    loanModel.totalInterest = totalInterest;
    loanModel.totalPayment = totalPayment;
    
    NSMutableArray <JXLoanEveryMonthPayModel *> *everyMonthPayModelsTemp = [[NSMutableArray alloc]  init];
    
    
    for (NSInteger i = 0; i < loanMonths; i ++) {
        JXLoanEveryMonthPayModel *model = [[JXLoanEveryMonthPayModel alloc] init];
        model.monthIndex = i + 1;
        CGFloat powTemp = pow(1 + monthlyRate, i);
        model.monthlyPaymentPrinciple = totalLoan * monthlyRate * powTemp / denominator;
        CGFloat currentInterest = totalLoan * monthlyRate * (pow0 - powTemp) / denominator;
        model.monthlyPaymentInterest = currentInterest;
        model.monthlyTotalPay = monthlyTotalPay;
        model.remain = (loanMonths - i - 1) * monthlyTotalPay;

        //
        [everyMonthPayModelsTemp addObject:model];
    }
    loanModel.everyMonthPayModels = [everyMonthPayModelsTemp copy];
    return loanModel;
}

+ (JXLoanModel *)calcFixedBasisWithAmount:(CGFloat)amount dueTime:(NSInteger)dueTime interestRate:(CGFloat)interestRate {
    CGFloat totalLoan = amount * 10000;
    NSInteger loanMonths = dueTime;
    CGFloat monthlyRate = interestRate / 12.f / 100.f;
    CGFloat totalInterest = (loanMonths + 1) * totalLoan * monthlyRate / 2;
    CGFloat totalPayment = totalInterest + totalLoan;
    CGFloat monthlyPaymentPrinciple = totalLoan * 1.f / loanMonths;
    
    //
    JXLoanModel *loanModel = [[JXLoanModel alloc] init];
    loanModel.loanType = JXLoanTypeFixedBasis;
    loanModel.totalLoan = totalLoan;
    loanModel.loanMonths = loanMonths;
    loanModel.totalInterest = totalInterest;
    loanModel.totalPayment = totalPayment;
    
    NSMutableArray <JXLoanEveryMonthPayModel *> *everyMonthPayModelsTemp = [[NSMutableArray alloc]  init];
    CGFloat hadPay = 0.f;
    for (NSInteger i = 0; i < loanMonths; i ++) {
        JXLoanEveryMonthPayModel *model = [[JXLoanEveryMonthPayModel alloc] init];
        model.monthIndex = i + 1;
        model.monthlyPaymentPrinciple = monthlyPaymentPrinciple;
        CGFloat currentInterest = (totalLoan - monthlyPaymentPrinciple * i) * monthlyRate;
        model.monthlyPaymentInterest = currentInterest;
        CGFloat monthlyTotalPay = monthlyPaymentPrinciple + currentInterest;
        model.monthlyTotalPay = monthlyTotalPay;
        hadPay += monthlyTotalPay;
        model.remain = totalPayment - hadPay;
        
        //
        [everyMonthPayModelsTemp addObject:model];
    }
    loanModel.everyMonthPayModels = [everyMonthPayModelsTemp copy];
    
    return loanModel;
}

@end










