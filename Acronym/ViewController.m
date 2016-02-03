//
//  ViewController.m
//  Acronym
//
//  Created by Kumar, Himanshu (TCS) on 2/2/16.
//  Copyright © 2016 Kumar, Himanshu (TCS). All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "MBProgressHUD.h"
#import "DetailAcronymTableViewController.h"

#define ACRONYM_WEBSERVICE @"http://www.nactem.ac.uk/software/acromine/dictionary.py"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *acronymSearchTextField;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;
@property (strong, nonatomic) NSArray *response;
@property (nonatomic) NSInteger noOfRows;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Intialize the no of rows for the table view by zero.
    _noOfRows = 0;
    
    self.title = @"Acronym";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [_acronymSearchTextField resignFirstResponder];
    
    // Bring the activity indicator before hitting the acronym web service.
    MBProgressHUD *mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mbProgressHUD.label.text = @"Sending";
    mbProgressHUD.detailsLabel.text = @"Please wait";
    mbProgressHUD.userInteractionEnabled = NO;
    
    [self searchAcronym:textField.text];
    
    return YES;
}

#pragma mark - Public Methods

- (void)searchAcronym:(NSString *)textTOSearch
{
    // Call request manager with the input
    AFHTTPRequestOperationManager *requestManager = [AFHTTPRequestOperationManager manager];
    requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // set the web service input
    NSMutableDictionary *inputDictionry = [[NSMutableDictionary alloc] init];
    [inputDictionry setObject:textTOSearch forKey:@"sf"];
    
    [requestManager POST:ACRONYM_WEBSERVICE parameters:inputDictionry success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        //Decode web service response from NSdata to NSString
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        // Make a json NSArray from NSString
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options:0 error:NULL];
        
        // Parse the webservice response in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self parseResponse:responseArray];
        });
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        // For network failure scenarion show the alert view
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Acronym" message:@"We're sorry. This service is currently unavailable. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                                 //Reset the text field and reload the table view after dismissing the alet view
                                 _acronymSearchTextField.text = nil;
                                 
                                 _noOfRows = 0;
                                 
                                 [_resultTableView reloadData];
                             }];
        
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        // Stop the activity indicator in case of failure condition
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)parseResponse:(NSArray *)responseArray
{
    // If web service returns no acronym show an alert says "No acronym to show for this text."
    if (responseArray.count == 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Acronym" message:@"No acronym to show for this text." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                                 //Reset the text field after dismissing the alet view

                                 _acronymSearchTextField.text = nil;
                             }];
        
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }

    // reload the table view and stop activity indicator after web service response parsing is complete
    _response = [[responseArray firstObject] valueForKey:@"lfs"];
        
    _noOfRows = [_response count];
    
    [_resultTableView reloadData];

    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _noOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    // Assign the response values of accrony and since used to text and detail text label respectively
    cell.textLabel.text = [[_response objectAtIndex:indexPath.row] valueForKey:@"lf"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Since : %@",[[[_response objectAtIndex:indexPath.row] valueForKey:@"since"] stringValue]];
    
    return cell;
}


// Use navigational push to bring the DetailAcronymTableViewController which shows details about each acronym

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DetailAcronymTableViewController *detailAcronymTableViewController = [sb instantiateViewControllerWithIdentifier:@"DetailAcronymTableViewController"];
    detailAcronymTableViewController.detailAcronym = [[_response objectAtIndex:indexPath.row] valueForKey:@"vars"];
    [self.navigationController pushViewController:detailAcronymTableViewController animated:YES];
}

@end
