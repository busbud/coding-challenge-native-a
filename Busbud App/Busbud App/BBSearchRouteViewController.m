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

@interface BBSearchRouteViewController ()

@end

@implementation BBSearchRouteViewController

@synthesize destinations;
@synthesize currentLocation;

-(IBAction)getCurrentLocation:(id)sender {
    // get location updates until we have a fresh location
    NSLog(@"Get location");
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

    // arbitrarily set current location
    // TODO: get GPS location and get location from API
    BBLocation *myLocation = [[BBLocation alloc] initWithName:@"Montréal" fullname:@"Montréal, Québec, Canada" urlform:@"Montreal,Quebec,Canada"];
    self.currentLocation = myLocation;
    
    self.departureCityLabel.text = self.currentLocation.name;
    
    // populate the destinations with dummy data
    // TODO: get valid destinations from current location from the API
    self.destinations = [[NSMutableArray alloc] initWithCapacity:30];
    for (int i = 0; i < 20; i++) {
        BBLocation *dest = [[BBLocation alloc] initWithName:@"Location" fullname:@"FullName" urlform:@"SaintJerome,Quebec,Canada"];
        
        [self.destinations addObject:dest];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - before segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    BBWebViewController *webController = segue.destinationViewController;
    
    NSString *urlToLoad = [NSString stringWithFormat:@"http://www.busbud.com/en/bus-schedules/%@/%@", self.currentLocation.urlform, (NSString*)sender];
    
    webController.url = urlToLoad;
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BBLocation *dest = [self.destinations objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showRouteSchedule" sender:[dest urlform]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UITableViewDataSource
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [destinations count];
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
    BBLocation *cellDestination = [destinations objectAtIndex:indexPath.row];
    cell.textLabel.text = cellDestination.name;
    
    return cell;
}



@end
