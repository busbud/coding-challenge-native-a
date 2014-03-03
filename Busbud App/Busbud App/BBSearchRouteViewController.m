//
//  BBSearchRouteViewController.m
//  Busbud App
//
//  Created by Dan Greencorn on 3/1/2014.
//  Copyright (c) 2014 Dan Greencorn. All rights reserved.
//

#import "BBSearchRouteViewController.h"
#import "BBLocation.h"
#import "BBWebViewController.h"
#import "conf.h"

@interface BBSearchRouteViewController ()

@end

@implementation BBSearchRouteViewController

@synthesize destinations = _destinations;
@synthesize currentLocation = _currentLocation;

-(void) setCurrentLocation:(BBLocation *)currentLocation {
    _currentLocation = currentLocation;
    
    // update the departure city label
    self.departureCityLabel.text = _currentLocation.name;
    NSLog(@"Setting label to : %@", _currentLocation.name);
    
    // reload destinations if currentLocation is not nil
    if (currentLocation != nil) {
        
        // clear the results
        self.destinations = nil;
        
        // fetch new destinations from the API
        [self getNewDestinations];
    }
}

-(void) setDestinations:(NSMutableArray *)destinations {
    _destinations = destinations;
    
    // reload the table view everytime the data changes
    [self.destinationTableView reloadData];
}

-(void) getNewDestinations  {
    // Make API call to get destinations from GET /:lang/api/v1/search/locations-from/:origin_city.urlform
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/api/v1/search/locations-from/%@", BUSBUD_API_BASE, BUSBUD_DEFAULT_LANGUAGE, self.currentLocation.urlform];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request addValue:BUSBUD_APP_ID forHTTPHeaderField:@"X-Busbud-Application-ID"];
    [request addValue:[[UIDevice currentDevice].identifierForVendor UUIDString] forHTTPHeaderField:@"X-Busbud-Device-Token"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

#pragma mark - UIViewController
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

    self.navigationItem.titleView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavBarImage"]];

    // remove separators in table view for "phantom cells"
    self.destinationTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // update the departure city label and destinations list
    self.departureCityLabel.text = _currentLocation.name;
    [self.destinationTableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.destinations = nil;
}

#pragma mark - before segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    BBWebViewController *webController = segue.destinationViewController;
    
    NSString *urlToLoad = [NSString stringWithFormat:@"http://www.busbud.com/%@/bus-schedules/%@/%@", BUSBUD_DEFAULT_LANGUAGE, self.currentLocation.urlform, (NSString*)sender];
    
    webController.url = urlToLoad;
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BBLocation *dest = [self.destinations objectAtIndex:indexPath.row];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad
        UISplitViewController *splitView = (UISplitViewController*)[[[[UIApplication sharedApplication] delegate] window]rootViewController];
        NSLog(@"%@",[splitView viewControllers]);
        BBWebViewController *webViewController = [[splitView viewControllers] objectAtIndex:1];
        NSString *urlToLoad = [NSString stringWithFormat:@"http://www.busbud.com/%@/bus-schedules/%@/%@", BUSBUD_DEFAULT_LANGUAGE, self.currentLocation.urlform, [dest urlform]];
        
        webViewController.url = urlToLoad;
    } else {
        // iPod/iPhone
        [self performSegueWithIdentifier:@"showRouteSchedule" sender:[dest urlform]];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - UITableViewDataSource
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.destinations count];
}

-(int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // get a reusable cell or create a new instance, if needed
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"destinationCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    // configure the cell with the destination details
    BBLocation *cellDestination = [self.destinations objectAtIndex:indexPath.row];
    cell.textLabel.text = cellDestination.name;
    
    return cell;
}

#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error;
    NSDictionary* responseDict = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  
                                  options:kNilOptions
                                  error:&error];
    
    NSLog(@"%@", responseDict);
    NSArray *responseLocations = [responseDict objectForKey:@"locations"];
    
    NSMutableArray *destinations = [[NSMutableArray alloc] initWithCapacity:[responseLocations count]];
    
    for (NSDictionary *loc in responseLocations) {
        BBLocation *destination = [[BBLocation alloc] initWithName:[loc objectForKey:@"name"] fullname:[loc objectForKey:@"fullname"] urlform:[loc objectForKey:@"urlform"]];
        
        [destinations addObject:destination];
    }
    
    self.destinations = destinations;
}


@end
