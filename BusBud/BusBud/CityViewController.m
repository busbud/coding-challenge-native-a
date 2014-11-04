//
//  CityViewController.m
//  BusBud
//
//  Created by Chris Comeau on 2014-11-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "CityViewController.h"

@interface CityViewController ()
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;


@end

@implementation CityViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //table
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor whiteColor];
    
    //don't show empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //subscribe to location updates
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedLocation:)
                                                 name:kNewLocationNotification
                                               object:nil];

    [kAppDelegate startUpdatingLocation];
    
    //no location, alert
    if(![kAppDelegate isLocationAvailable]) {

        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"kStringError", nil)
                              message:NSLocalizedString(@"kStringLocationUnavailableError", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"kStringOK", nil)
                              otherButtonTitles:nil];
        [alert show];
    }
    
    //location
    self.latitude = kAppDelegate.locationManager.location.coordinate.latitude;
    self.longitude = kAppDelegate.locationManager.location.coordinate.longitude;

    [self updateData];
    [self updateUI];

}

-(void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewLocationNotification object:nil];
}



#pragma mark -
#pragma mark - Methods

- (void)updateData {
    
    

}

- (void)updateUI {
    
    [self.tableView reloadData];
}


#pragma mark - Actions

- (IBAction)actionBack:(id)sender {
    if(self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //test
    int count = 3;
    return count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    //style
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kColorBlueCell;
    cell.textLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:14.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    //test
    cell.textLabel.text = @"test";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self actionBack:nil];
}


#pragma mark - Location

-(void) updatedLocation:(NSNotification*)notif {
    
    self.latitude = kAppDelegate.locationManager.location.coordinate.latitude;
    self.longitude = kAppDelegate.locationManager.location.coordinate.longitude;
    
    [self updateData];
    [self updateUI];
}


@end
