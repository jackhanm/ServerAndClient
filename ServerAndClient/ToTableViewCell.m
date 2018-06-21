//
//  ToTableViewCell.m
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/26.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "ToTableViewCell.h"
#import "MessageModel.h"
@interface ToTableViewCell ()

@property (nonatomic, strong) UILabel *messageLabel;
//@property (nonatomic, strong)
@end

@implementation ToTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.messageLabel setNumberOfLines:0];
    [self.messageLabel.layer setMasksToBounds:YES];
    [self.messageLabel setBackgroundColor:[UIColor greenColor]];
    [self.messageLabel.layer setCornerRadius:10];
    [self.contentView addSubview:self.messageLabel];
}
- (void)setModel:(MessageModel *)model
{
    if (_model != model) {
        _model = model;
        [self changeMessageLabel];
    }
}
- (void)changeMessageLabel
{
    CGRect rect = [UIScreen mainScreen].bounds;
    NSDictionary *dic = @{NSFontAttributeName:self.messageLabel.font};
    CGSize size = [self.model.message boundingRectWithSize:CGSizeMake(rect.size.width / 3 * 2, 100000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    [self.messageLabel setText:self.model.message];
    [self.messageLabel setFrame:CGRectMake(0, 0, size.width, size.height)];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
