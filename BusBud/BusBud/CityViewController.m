//
//  CityViewController.m
//  BusBud
//
//  Created by Chris Comeau on 2014-11-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "CityViewController.h"
#import "HomeViewController.h"

@interface CityViewController ()
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (strong, nonatomic) NSString *foundCityString;


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
    
    self.foundCityString = nil;
    
    //test
    if([kAppDelegate isValidLatitude:self.latitude andLongitude:self.longitude]) {
        self.foundCityString =[NSString stringWithFormat:@"%f, %f", self.latitude, self.longitude];
    }

    
    return;
    
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"kStringSearching", nil)];

    
    
    [SVProgressHUD dismiss];
    [self updateUI];


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
    
    
    //data
    cell.textLabel.text = NSLocalizedString(@"kStringUnknown", nil);

    if(indexPath.row == 0) {
        //1st row
        if(self.foundCityString) {
            //show city
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"kStringMyLocation", nil), self.foundCityString];
        }
        else {
            //not found,
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"kStringMyLocation", nil), NSLocalizedString(@"kStringUnknown", nil)];

        }
        
    }
    else {
        //normal
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //previous controller
    HomeViewController *controller = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];

    if(indexPath.row == 0) {
        
        //1st row
        
        if(self.foundCityString) {
            //good
            
            //test
            if(self.searchType == SearchTypeFrom) {
                controller.fromString = self.foundCityString;
                controller.fromStringFull = self.foundCityString;
            }
            else{
                controller.toString = self.foundCityString;
                controller.toStringFull = self.foundCityString;
            }
        }
        
        else{
            //no location found
            //[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"kStringLocationUnavailableError", nil)];
            
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"kStringError", nil)
                                  message:NSLocalizedString(@"kStringLocationUnavailableError", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"kStringOK", nil)
                                  otherButtonTitles:nil];
            [alert show];

            return;
        }
        
        ;
        
    }
    else {
        //normal
        
        //test
        if(self.searchType == SearchTypeFrom) {
            controller.fromString = @"Montreal,Quebec,Canada";
            controller.fromStringFull = @"Montreal, Quebec, Canada";
        }
        else{
            controller.toString = @"Toronto,Ontario,Canada";
            controller.toStringFull = @"Montreal, Quebec, Canada";
        }

    }
    
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
