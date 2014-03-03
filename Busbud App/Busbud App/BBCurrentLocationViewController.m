//
//  BBCurrentLocationViewController.m
//  Busbud App
//
//  Created by Dan Greencorn on 3/3/2014.
//  Copyright (c) 2014 Dan Greencorn. All rights reserved.
//

#import "BBCurrentLocationViewController.h"
#import "BBSearchRouteViewController.h"
#import "BBLocation.h"
#import "conf.h"

@interface BBCurrentLocationViewController ()

@end

@implementation BBCurrentLocationViewController

@synthesize findRouteButton;
@synthesize loadingLabel;
@synthesize activityView;
@synthesize currentLocation;
@synthesize currentBBLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // initialize currentLocation to nil
    self.currentLocation = nil;
    
    // initialize the location manager
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager setDistanceFilter:0];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // reset our currentLocation to nil
    self.currentLocation = nil;
    
    // start getting location updates
    [locationManager startUpdatingLocation];
    
    [self showLoading];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // get the most recent location
    CLLocation *location = manager.location;
    NSLog(@"Location Update: \n\tlat:%f\n\tLon:%f\n\tErr:%f", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    
    // if we have a good fresh location (within 15 seconds)
    if ( [location.timestamp timeIntervalSinceNow] >= -15.0) {
        
        // set the location as our currentLocation
        currentLocation = location;
        
        // stop getting location updates
        [locationManager stopUpdatingLocation];
        NSLog(@"Stop Updating");
        
        // get API geocoded location
        [self getAPILocation:currentLocation];
    }
}

-(void)getAPILocation:(CLLocation*)location {
    NSString *requestURL = [NSString stringWithFormat:@"%@//%@/api/v1/search/locations/?latitude=%f&longitude=%f&accuracy=%f",BUSBUD_API_BASE, BUSBUD_DEFAULT_LANGUAGE, location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL]];
    
    request.HTTPMethod = @"GET";
    
    [request addValue:BUSBUD_APP_ID forHTTPHeaderField:@"X-Busbud-Application-ID"];
    [request addValue:[[UIDevice currentDevice].identifierForVendor UUIDString] forHTTPHeaderField:@"X-Busbud-Device-Token"];
    
    
    //NSLog(request.allHTTPHeaderFields);
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection Error: Request for location in busbud API");
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error;
    NSDictionary* responseDict = [NSJSONSerialization
                          JSONObjectWithData:data
                          
                          options:kNilOptions
                          error:&error];
    
    NSLog(@"API RESPONSE");
    NSLog(@"%@",responseDict);
    
    NSDictionary *current = [responseDict objectForKey:@"current"];
    
    currentBBLocation = [[BBLocation alloc] initWithName:[current objectForKey:@"name"] fullname:[current objectForKey:@"fullname"] urlform:[current objectForKey:@"urlform"]];
    
    [self showFindRoutes];
}

-(void) showFindRoutes {
    loadingLabel.hidden = YES;
    activityView.hidden = YES;
    [activityView stopAnimating];
    
    findRouteButton.hidden = NO;
}

-(void) showLoading {
    loadingLabel.hidden = NO;
    loadingLabel.text = @"Loading...";
    activityView.hidden = NO;
    [activityView startAnimating];
    
    findRouteButton.hidden = YES;
}

-(void) showError:(NSString*)message {
    loadingLabel.hidden = NO;
    loadingLabel.text = message;
    
    activityView.hidden = YES;
    [activityView stopAnimating];
    
    findRouteButton.hidden = YES;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [(BBSearchRouteViewController*)segue.destinationViewController setCurrentLocation:self.currentBBLocation];
}



@end
