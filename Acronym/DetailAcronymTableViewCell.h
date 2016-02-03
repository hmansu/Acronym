//
//  DetailAcronymTableViewCell.h
//  Acronym
//
//  Created by Kumar, Himanshu (TCS) on 2/3/16.
//  Copyright © 2016 Kumar, Himanshu (TCS). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailAcronymTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *detailAcronymText;
@property (weak, nonatomic) IBOutlet UILabel *usedSince;
@property (weak, nonatomic) IBOutlet UILabel *frequency;

@end
