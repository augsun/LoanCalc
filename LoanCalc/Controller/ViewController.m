//
//  ViewController.m
//  LoanCalc
//
//  Created by augsun on 3/5/17.
//  Copyright © 2017 sun. All rights reserved.
//

#import "ViewController.h"
#import "JXLoanEveryMonthPayCell.h"
#import "JXLoanDueTimeSelectView.h"

static NSString *const kCellID = @"kCellID";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *interestRateTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)btnDueTimeClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *dueTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalPaymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalInterestLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLoanLabel;
@property (weak, nonatomic) IBOutlet UILabel *loanMonthsLabel;

- (IBAction)segmentValueChange:(UISegmentedControl *)sender;
- (IBAction)btnHeaderBgClick:(id)sender;

@property (nonatomic, strong) JXLoanModel *loanModel;
@property (nonatomic, assign) JXLoanType loanType;

@property (nonatomic, copy) NSString *amountText;
@property (nonatomic, copy) NSString *dueTimeText;
@property (nonatomic, copy) NSString *interestRateText;

@property (nonatomic, strong) JXLoanDueTimeSelectView *dueTimeSelectView;

@property (nonatomic, assign) CGFloat amount;
@property (nonatomic, assign) NSInteger months;
@property (nonatomic, assign) CGFloat interestRate;

- (IBAction)rightRefreshItemClick:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([JXLoanEveryMonthPayCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kCellID];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 30.f;
    _dueTimeSelectView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JXLoanDueTimeSelectView class]) owner:nil options:nil] firstObject];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChangeNotification:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    self.loanType = JXLoanTypeFixedPayment;

    
}

- (void)setLoanType:(JXLoanType)loanType {
    _loanType = loanType;
    [self refreshUI];
}

- (void)textFieldTextDidChangeNotification:(NSNotification *)noti {
    UITextField *textFieldTemp = noti.object;
    NSString *textTemp = textFieldTemp.text;
    
    if (textFieldTemp == self.amountTextField || textFieldTemp == self.interestRateTextField) {
        if (textFieldTemp == self.amountTextField) {
            if ([textTemp isEqualToString:@""]) {
                self.amount = 0;
            }
            else {
                NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
                self.amountTextField.text = [[textTemp componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
                self.amount = [self.amountTextField.text floatValue];
            }
        }
        
        //
        if (textFieldTemp == self.interestRateTextField) {
            if ([textTemp isEqualToString:@""]) {
                self.interestRate = 0.f;
            }
            else {
                NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
                self.interestRateTextField.text = [[textTemp componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
                self.interestRate = [self.interestRateTextField.text floatValue];
            }
        }
        
        [self refreshUI];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.loanModel.everyMonthPayModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JXLoanEveryMonthPayCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    cell.model = self.loanModel.everyMonthPayModels[indexPath.row];
    return cell;
}

- (IBAction)segmentValueChange:(UISegmentedControl *)sender {
    [self.view endEditing:YES];
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            self.loanType = JXLoanTypeFixedPayment;
            [self refreshUI];
        } break;
            
        case 1:
        {
            self.loanType = JXLoanTypeFixedBasis;
            [self refreshUI];
        } break;
            
        default: break;
    }
}

- (IBAction)btnHeaderBgClick:(id)sender {
    [self.view endEditing:YES];
}

- (void)refreshUI {
    if (self.months == 0) {
        self.dueTimeLabel.text = @"0 month";
        self.dueTimeLabel.textColor = [UIColor colorWithRed:199/255.f green:199/255.f blue:204/255.f alpha:1.f];
    }
    else {
        NSInteger years = self.months / 12;
        NSInteger months = self.months % 12;
        if (years == 0) {
            self.dueTimeLabel.text = [NSString stringWithFormat:@"%ld month%@", months, months == 1 ? @"" : @"s"];
        }
        else if (months == 0) {
            self.dueTimeLabel.text = [NSString stringWithFormat:@"%ld year%@", years, years == 1 ? @"" : @"s"];
        }
        else {
            self.dueTimeLabel.text = [NSString stringWithFormat:@"%ld year%@ & %ld month%@", years, years == 1 ? @"" : @"s", months, months == 1 ? @"" : @"s"];
        }
        self.dueTimeLabel.textColor = [UIColor colorWithRed:242/255.f green:192/255.f blue:86/255.f alpha:1.f];
    }
    
    if (self.amount <= 0) {
        [self resetUI];
        return;
    }
    
    if (self.months <= 0) {
        [self resetUI];
        return;
    }
    
    if (self.interestRate <= 0) {
        [self resetUI];
        return;
    }
    
    self.loanModel = [JXLoanModel calcWithType:self.loanType
                                        amount:self.amount
                                       dueTime:self.months
                                  interestRate:self.interestRate];
    
    if (self.loanModel) {
        self.totalPaymentLabel.text = self.loanModel.totalPaymentString;
        self.totalInterestLabel.text = self.loanModel.totalInterestString;
        self.totalLoanLabel.text = self.loanModel.totalLoanString;
        self.loanMonthsLabel.text = self.loanModel.loanMonthsString;
        [self.tableView reloadData];
    }
    else {
        [self resetUI];
    }
}

- (void)resetUI {
    self.totalPaymentLabel.text = @"---";
    self.totalInterestLabel.text = @"---";
    self.totalLoanLabel.text = @"---";
    self.loanMonthsLabel.text = @"---";
    self.loanModel = nil;
    [self.tableView reloadData];
}

- (IBAction)btnDueTimeClick:(id)sender {
    [self.view endEditing:YES];
    __weak __typeof(self) weakSelf = self;
    [self.dueTimeSelectView showWithOK:^(NSInteger years, NSInteger months) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.months = years * 12 + months;
        [self refreshUI];
    }];
}

- (IBAction)rightRefreshItemClick:(id)sender {
    [self.view endEditing:YES];
    self.amountTextField.text = nil;
    self.interestRateTextField.text = nil;
    self.months = 0;
    [self refreshUI];
}

@end










