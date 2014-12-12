//
//  ViewController.m
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-27.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import "ViewController.h"
#import "BBClient.h"
#import "BBCity.h"
#import "Busbud-Swift.h"
#import "SearchTableViewController.h"

#import <FXKeychain/FXKeychain.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <SVProgressHUD/SVProgressHUD.h>

@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate, UISearchResultsUpdating, SearchTableViewControllerDelegate>

@property (nonatomic, strong) BBClient *client;
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) BBCity *origin;
@property (nonatomic, strong) BBCity *destination;

@property (nonatomic, copy) NSArray *destinations;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation ViewController

- (void)viewDidLoad {
    self.tableView.backgroundView.backgroundColor = UIColor.redColor;
    
    self.client = [[BBClient alloc] initWithEndpoint: [NSURL URLWithString: @"https://busbud-napi-prod.global.ssl.fastly.net"]
                                              locale: NSLocale.currentLocale
                                            keychain: [FXKeychain defaultKeychain]];

    // Setup search controller
    self.definesPresentationContext = YES;
    SearchTableViewController *searchController = [[SearchTableViewController alloc] initWithClient: self.client];
    searchController.searchDelegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController: searchController];
    self.searchController.searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.);
    self.searchController.searchResultsUpdater = self;
    
    self.originContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchController.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.originContainer addSubview: self.searchController.searchBar];
    [self.originContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"|-5-[searchBar]-5-|"
                                                                                  options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                  metrics: @{}
                                                                                    views: @{@"searchBar": self.searchController.searchBar}]];
    
    // Use Busbud logo
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"logo"]];
    
    [self.tableView registerClass: UITableViewCell.class forCellReuseIdentifier: @"CityCell"];

    @weakify(self);
    [[[[RACObserve(self, origin) deliverOn: RACScheduler.mainThreadScheduler] doNext:^(BBCity *origin) {
        @strongify(self);
        self.searchController.searchBar.text = origin.fullname;
        NSString *status = NSLocalizedString(@"SEARCHING_DESTINATIONS", @"Searching for destinations hud message");
        [SVProgressHUD showWithStatus: status maskType: SVProgressHUDMaskTypeBlack];
    }] flattenMap:^RACStream *(BBCity *originCity) {
        @strongify(self);
        NSLog(@"Origin city changed : loading destinations");
        return [[[self.client search: nil around: nil origin: originCity] collect] deliverOn: RACScheduler.mainThreadScheduler];
    }] subscribeNext:^(NSArray *destinations) {
        @strongify(self);
        NSLog(@"Destinations = %@", destinations);
        self.destinations = destinations;
        NSLog(@"Reloading");
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } error:^(NSError *error) {
        NSLog(@"Got error = %@", error);
    }];
    
    self.manager = [[CLLocationManager alloc] init];
    [self.manager requestWhenInUseAuthorization];
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *scheduleUrl = [NSString stringWithFormat: @"https://www.busbud.com/%@/bus-schedules/%@/%@", [NSLocale.currentLocale objectForKey: NSLocaleLanguageCode], self.origin.url, self.destination.url];
    
    BrowserViewController *controller = (BrowserViewController *)segue.destinationViewController;
    controller.url = [NSURL URLWithString: scheduleUrl];
}

#pragma mark CLLocationManager
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Unable to retrieve your location %@", error);
    [SVProgressHUD showErrorWithStatus: NSLocalizedString(@"LOCATION_MANAGER_ERROR", @"Error displayed when the location cannot be retrieved")];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];

    @weakify(self);
    RACSignal *searchSignal = [[self.client search: nil around: locations.firstObject origin: nil] collect];
    [[searchSignal map:^id(NSArray *results) {
        return results.firstObject;
    }] subscribeNext: ^(BBCity *originCity) {
        @strongify(self);
        self.origin = originCity;
    }];
}

#pragma mark UITableViewDelegate / UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBCity *city = self.destinations[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CityCell" forIndexPath: indexPath];
    cell.textLabel.text = city.fullname;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.destination = self.destinations[indexPath.row];
    [self performSegueWithIdentifier: @"ToSchedules" sender: self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.destinations.count;
}

#pragma mark UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *newTerms = searchController.searchBar.text;
    NSLog(@"NewTerms is = %@", newTerms);
    [(SearchTableViewController *)searchController.searchResultsController updateWithSearchResultsFor: newTerms];
}

#pragma mark SearchTableViewControllerDelegate
- (void)searchTableViewController:(SearchTableViewController *)controller didSelectCity:(BBCity *)city {
    self.origin = city;
    [self.searchController dismissViewControllerAnimated: YES completion: nil];
}

@end
