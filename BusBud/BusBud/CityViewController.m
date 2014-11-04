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
@property (strong, nonatomic) NSArray *citiesArray;

@end

@implementation CityViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //title

    self.title = NSLocalizedString(@"kTitleCity", nil);
    
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
    
    //hide
    [SVProgressHUD dismiss];
}



#pragma mark -
#pragma mark - Methods

- (void)updateData {
    
    self.foundCityString = nil;
    self.citiesArray = nil;
    
    //valid location
    if(![kAppDelegate isValidLatitude:self.latitude andLongitude:self.longitude]) {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"kStringError", nil)
                              message:NSLocalizedString(@"kStringLocationUnavailableError", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"kStringOK", nil)
                              otherButtonTitles:nil];
        [alert show];

        
        [self updateUI];
        return;
    }
    
    
    //token
    if(!kAppDelegate.apiToken) {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"kStringError", nil)
                              message:NSLocalizedString(@"kStringErrorToken", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"kStringOK", nil)
                              otherButtonTitles:nil];
        [alert show];
        
        
        [self updateUI];
        return;
    }
    
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"kStringSearching", nil)];
    
    NSString * urlString = nil;
    urlString = [NSString stringWithFormat:kAPICity, self.languageString, self.latitude, self.longitude];
    NSLog(@"url: %@", urlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    //token
    [request setValue:kAppDelegate.apiToken forHTTPHeaderField:@"X-Busbud-Token"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject){
        
        [SVProgressHUD dismiss];

        NSData* data =  [operation responseData];
        NSError* error;
        NSArray* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&error];
        
        //check error
        if(error != nil) {
            NSLog(@"JSON error");
        } else {
            NSLog(@"JSON success: %@", json);
            
            //copy
            if(json) {
                self.citiesArray = json;
            }
        }
        
        [self updateUI];
        
    }failure:^(AFHTTPRequestOperation* operation, NSError* error){
        //error
        [SVProgressHUD dismiss];

        NSLog(@"Error getting cities ");
        
        [self updateUI];

    }];
    
    [operation start];
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
    int count = 0;
    if(self.citiesArray) {
        count = (int)self.citiesArray.count;
    }
        
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
    cell.textLabel.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:16.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    
    //data
    cell.textLabel.text = NSLocalizedString(@"kStringUnknown", nil);

    NSDictionary *dict = [self.citiesArray objectAtIndex:indexPath.row];
    
    NSString *cityString = [dict objectForKey:@"full_name"];
    cell.textLabel.text = cityString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //previous controller
    HomeViewController *controller = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    NSDictionary *dict = [self.citiesArray objectAtIndex:indexPath.row];
    NSString *cityString = [dict objectForKey:@"full_name"];
    NSString *cityStringURL = [dict objectForKey:@"city_url"];
    self.foundCityString = cityString;
    
    //set
    if(self.searchType == SearchTypeFrom) {
        controller.fromString = cityStringURL;
        controller.fromStringFull = cityString;
    }
    else{
        controller.toString = cityStringURL;
        controller.toStringFull = cityString;
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
