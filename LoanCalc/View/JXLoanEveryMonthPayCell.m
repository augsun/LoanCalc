//
//  JXLoanEveryMonthPayCell.m
//  LoanCalc
//
//  Created by augsun on 3/5/17.
//  Copyright © 2017 sun. All rights reserved.
//

#import "JXLoanEveryMonthPayCell.h"

@interface JXLoanEveryMonthPayCell ()

@property (weak, nonatomic) IBOutlet UILabel *monthIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *baseLoanLabel;
@property (weak, nonatomic) IBOutlet UILabel *interestLabel;
@property (weak, nonatomic) IBOutlet UILabel *needPayLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainLabel;

@end

@implementation JXLoanEveryMonthPayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setModel:(JXLoanEveryMonthPayModel *)model {
    _model = model;
    
    self.monthIndexLabel.text = model.monthIndexString;
    self.baseLoanLabel.text = model.monthlyPaymentPrincipleString;
    self.interestLabel.text = model.monthlyPaymentInterestString;
    self.needPayLabel.text = model.monthlyTotalPayString;
    self.remainLabel.text = model.remainString;
}
@end
