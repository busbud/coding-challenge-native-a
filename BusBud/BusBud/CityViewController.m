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
@property (nonatomic, strong) IBOutlet UITextField *textView;

@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) BOOL alreadyUpdating;
@property (strong, nonatomic) NSString *foundCityString;
@property (strong, nonatomic) NSArray *citiesArray;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation CityViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //title
    self.title = NSLocalizedString(@"kTitleCity", nil);
    
    //text
    self.textView.delegate = self;
    self.textView.textColor = RGB(20,20,20);

    self.textView.font = [UIFont fontWithName:@"AshemoreSoftCondMedium" size:16.0];
    [self.textView addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

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
    
    if(self.alreadyUpdating)
        return;
    
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
    
    //hud
    [SVProgressHUD showWithStatus:NSLocalizedString(@"kStringSearching", nil)];
    
    NSString * urlString = nil;
    urlString = [NSString stringWithFormat:kAPICity, self.languageString, self.latitude, self.longitude];
    
    //origin
    if(self.fromId) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"%@%@", kAPICityOriginParam, self.fromId]];
    }
    
    //filter
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&q=%@",self.textView.text]];

    //encode
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"url: %@", urlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    
    self.alreadyUpdating = YES;

    //token
    [request setValue:kAppDelegate.apiToken forHTTPHeaderField:@"X-Busbud-Token"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject){
        
        self.alreadyUpdating = NO;

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
        self.alreadyUpdating = NO;

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
    NSString *cityId= [dict objectForKey:@"city_id"];
    self.foundCityString = cityString;
    
    //set
    if(self.searchType == SearchTypeFrom) {
        controller.fromString = cityStringURL;
        controller.fromStringFull = cityString;
        controller.fromId = cityId; //origin
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

#pragma mark - Text

- (void)textFieldDidChange:(id)sender
{
    //update now
    //[self updateData];

    //update with timer, debounce
    [self resetTimer];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
 
    return YES;
}

#pragma mark - Timer

- (void)resetTimer{
    
    [self.timer invalidate];
    self.timer = nil;
    
    float interval = 0.5f; //delay before triggering search
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self
                                                selector:@selector(actionTimer:) userInfo:@"actionTimer" repeats:NO];
    
}

- (void) actionTimer:(NSTimer *)incomingTimer
{
        [self updateData];
}


@end
