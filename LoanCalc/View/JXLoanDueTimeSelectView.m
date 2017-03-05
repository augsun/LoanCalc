//
//  JXLoanDueTimeSelectView.m
//  LoanCalc
//
//  Created by augsun on 3/5/17.
//  Copyright © 2017 sun. All rights reserved.
//

#import "JXLoanDueTimeSelectView.h"

@interface JXLoanDueTimeSelectView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spa_popViewToBottom;

@property (nonatomic, copy) void (^okBlock)(NSInteger, NSInteger);

@property (nonatomic, copy) NSArray <NSDictionary *> *componentYears;
@property (nonatomic, copy) NSArray <NSDictionary *> *componentMonths;

@property (nonatomic, assign) NSInteger years;
@property (nonatomic, assign) NSInteger months;

@end

@implementation JXLoanDueTimeSelectView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    _years = 0;
    _months = 0;
    
    NSMutableArray <NSDictionary *> *componentYearsTemp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 30; i ++) {
        NSMutableDictionary *dicTemp = [[NSMutableDictionary alloc] init];
        [dicTemp setObject:[NSString stringWithFormat:@"%ld year%@", i, (i == 0 || i == 1) ? @"" : @"s"] forKey:@"title"];
        [dicTemp setObject:[NSString stringWithFormat:@"%ld", i] forKey:@"year"];
        [componentYearsTemp addObject:dicTemp];
    }
    self.componentYears = [componentYearsTemp copy];
    
    NSMutableArray <NSDictionary *> *componentMonthsTemp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 12; i ++) {
        NSMutableDictionary *dicTemp = [[NSMutableDictionary alloc] init];
        [dicTemp setObject:[NSString stringWithFormat:@"%ld month%@", i, (i == 0 || i == 1) ? @"" : @"s"] forKey:@"title"];
        [dicTemp setObject:[NSString stringWithFormat:@"%ld", i] forKey:@"month"];
        [componentMonthsTemp addObject:dicTemp];
    }
    self.componentMonths = [componentMonthsTemp copy];
}

- (IBAction)btnOKClick:(id)sender {
    !self.okBlock ? : self.okBlock(self.years, self.months);
    [self btnBgClick:nil];
}

- (IBAction)btnBgClick:(id)sender {
    [UIView animateWithDuration:.25f animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.spa_popViewToBottom.constant = - (216 + 40);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showWithOK:(void (^)(NSInteger, NSInteger))ok {
    self.okBlock = ok;
    
    [self.pickerView reloadAllComponents];
    
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    self.spa_popViewToBottom.constant = - (216 + 40);
    [self layoutIfNeeded];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:.25f animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        self.spa_popViewToBottom.constant = 0.f;
        [self layoutIfNeeded];
    }];
}

#pragma mark <UIPickerViewDelegate>
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.componentYears.count;
    }
    else {
        return self.componentMonths.count;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *rowLabel = (UILabel *)view;
    if (!rowLabel) {
        rowLabel = [[UILabel alloc] init];
        rowLabel.textAlignment = NSTextAlignmentCenter;
        rowLabel.textColor = [UIColor colorWithRed:242/255.f green:192/255.f blue:86/255.f alpha:1.f];
        rowLabel.text = component == 0 ? self.componentYears[row][@"title"] : self.componentMonths[row][@"title"];
    }
    return rowLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.years = [self.componentYears[row][@"year"] integerValue];
    }
    else {
        self.months = [self.componentMonths[row][@"month"] integerValue];
    }
}

@end










