//
//  DetailAcronymTableViewController.m
//  Acronym
//
//  Created by Kumar, Himanshu (TCS) on 2/2/16.
//  Copyright © 2016 Kumar, Himanshu (TCS). All rights reserved.
//

#import "DetailAcronymTableViewController.h"
#import "DetailAcronymTableViewCell.h"

@interface DetailAcronymTableViewController ()

@end

@implementation DetailAcronymTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Details";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_detailAcronym count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //load custom cell
    static NSString *CellIdentifier = @"DetailAcronymTableViewCell";
    
    DetailAcronymTableViewCell *cell = (DetailAcronymTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (DetailAcronymTableViewCell *)[nib objectAtIndex:0];
    }
    
    // Configure the cell...
    // Assign the response values of accrony,since used and frequency to detailAcronymText, usedSince and frequency label respectively

    cell.detailAcronymText.text = [[_detailAcronym objectAtIndex:indexPath.row] valueForKey:@"lf"];
    cell.usedSince.text = [NSString stringWithFormat:@"Since: %@",[[[_detailAcronym objectAtIndex:indexPath.row] valueForKey:@"since"] stringValue]];
    cell.frequency.text = [NSString stringWithFormat:@"Frequency: %@",[[[_detailAcronym objectAtIndex:indexPath.row] valueForKey:@"freq"] stringValue]];
    return cell;

}

@end
