//
//  FMHotFundCell.m
//  FundMonitor
//

#import "FMHotFundCell.h"
#import "FMHotFundModel.h"

@interface FMHotFundCell ()

@property (nonatomic, strong) UILabel *fundNameLabel;
@property (nonatomic, strong) UILabel *fundCodeLabel;
@property (nonatomic, strong) UILabel *rateThisYearLabel;
@property (nonatomic, strong) UILabel *rate1MonthLabel;
@property (nonatomic, strong) UILabel *rate6MonthLabel;
@property (nonatomic, strong) UILabel *rate1YearLabel;

@end

@implementation FMHotFundCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 基金代码
    self.fundCodeLabel = [[UILabel alloc] init];
    self.fundCodeLabel.font = [UIFont systemFontOfSize:12];
    self.fundCodeLabel.textColor = [UIColor secondaryLabelColor];
    self.fundCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.fundCodeLabel];
    
    // 基金名称
    self.fundNameLabel = [[UILabel alloc] init];
    self.fundNameLabel.font = [UIFont boldSystemFontOfSize:14];
    self.fundNameLabel.textColor = [UIColor labelColor];
    self.fundNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.fundNameLabel];

    // 今年以来
    self.rateThisYearLabel = [[UILabel alloc] init];
    self.rateThisYearLabel.font = [UIFont systemFontOfSize:14];
    self.rateThisYearLabel.textColor = [UIColor secondaryLabelColor];
    self.rateThisYearLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rateThisYearLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.rateThisYearLabel];
    
    // 近1月
    self.rate1MonthLabel = [[UILabel alloc] init];
    self.rate1MonthLabel.font = [UIFont systemFontOfSize:14];
    self.rate1MonthLabel.textColor = [UIColor secondaryLabelColor];
    self.rate1MonthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rate1MonthLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.rate1MonthLabel];
    
    // 近6月
    self.rate6MonthLabel = [[UILabel alloc] init];
    self.rate6MonthLabel.font = [UIFont systemFontOfSize:14];
    self.rate6MonthLabel.textColor = [UIColor secondaryLabelColor];
    self.rate6MonthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rate6MonthLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.rate6MonthLabel];
    
    // 近1年
    self.rate1YearLabel = [[UILabel alloc] init];
    self.rate1YearLabel.font = [UIFont systemFontOfSize:14];
    self.rate1YearLabel.textColor = [UIColor secondaryLabelColor];
    self.rate1YearLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rate1YearLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.rate1YearLabel];
    
    // 布局
    [NSLayoutConstraint activateConstraints:@[
        // 基金名称
        [self.fundNameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
        [self.fundNameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        // 基金代码
        [self.fundCodeLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
        [self.fundCodeLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        // 今年以来
        [self.rateThisYearLabel.topAnchor constraintEqualToAnchor:self.fundNameLabel.bottomAnchor constant:13],
        [self.rateThisYearLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        // 近1月
        [self.rate1MonthLabel.topAnchor constraintEqualToAnchor:self.rateThisYearLabel.topAnchor constant:0],
        [self.rate1MonthLabel.leadingAnchor constraintEqualToAnchor:self.rateThisYearLabel.trailingAnchor],
        [self.rate1MonthLabel.widthAnchor constraintEqualToAnchor:self.rateThisYearLabel.widthAnchor],
        // 近6月
        [self.rate6MonthLabel.topAnchor constraintEqualToAnchor:self.rate1MonthLabel.topAnchor constant:0],
        [self.rate6MonthLabel.leadingAnchor constraintEqualToAnchor:self.rate1MonthLabel.trailingAnchor],
        [self.rate6MonthLabel.widthAnchor constraintEqualToAnchor:self.rate1MonthLabel.widthAnchor],
        // 近1年
        [self.rate1YearLabel.topAnchor constraintEqualToAnchor:self.rate6MonthLabel.topAnchor constant:0],
        [self.rate1YearLabel.leadingAnchor constraintEqualToAnchor:self.rate6MonthLabel.trailingAnchor],
        [self.rate1YearLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.rate1YearLabel.widthAnchor constraintEqualToAnchor:self.rate6MonthLabel.widthAnchor]
    ]];
}

- (void)setModel:(FMHotFundModel *)model {
    _model = model;

    self.fundNameLabel.text = model.fundName;
    self.fundCodeLabel.text = [NSString stringWithFormat:@"(%@)",model.fundCode];

    // 今年
    [self setTextWithRate:self.model.rateThisYear label:self.rateThisYearLabel];
    // 近1月
    [self setTextWithRate:self.model.rate1Month label:self.rate1MonthLabel];
    // 近6月
    [self setTextWithRate:self.model.rate6Month label:self.rate6MonthLabel];
    // 近1年
    [self setTextWithRate:self.model.rate1Year label:self.rate1YearLabel];
}

- (void)setTextWithRate:(NSString *)rateText label:(UILabel *)label
{
    if (rateText && rateText.length > 0) {
        double rate = [rateText doubleValue];
        label.text = [NSString stringWithFormat:@"%.2f%%", rate];
        if (rate > 0) {
            label.textColor = [UIColor systemRedColor];
        } else if (rate < 0) {
            label.textColor = [UIColor systemGreenColor];
        } else {
            label.textColor = [UIColor labelColor];
        }
    } else {
        label.text = @"--";
        label.textColor = [UIColor labelColor];
    }
}

@end
