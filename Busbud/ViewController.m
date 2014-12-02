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

#import <FXKeychain/FXKeychain.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) BBClient *client;
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) BBCity *origin;
@property (nonatomic, copy) NSArray *destinations;

@end

@implementation ViewController

- (void)viewDidLoad {
    self.client = [[BBClient alloc] initWithEndpoint: [NSURL URLWithString: @"https://busbud-napi-prod.global.ssl.fastly.net"]
                                              locale: NSLocale.currentLocale
                                            keychain: [FXKeychain defaultKeychain]];
    RAC(self.originCityField, text) = [[RACObserve(self, origin) deliverOn: RACScheduler.mainThreadScheduler] map:^id(BBCity *city) {
        return city.fullname;
    }];

    self.manager = [[CLLocationManager alloc] init];
    [self.manager requestWhenInUseAuthorization];
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Status = %@", @(status));
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failed with error %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];
    NSLog(@"Locations = %@", locations);
    
    RACSignal *searchSignal = [[self.client search: nil around: locations.firstObject origin: nil] collect];
    [[[[[searchSignal map:^id(NSArray *results) {
        return results.firstObject;
    }] doNext: ^(BBCity *originCity) {
        self.origin = originCity;
    }] flattenMap:^RACStream *(BBCity *originCity) {
        return [[self.client search: nil around: nil origin: originCity] collect];
    }] deliverOn: RACScheduler.mainThreadScheduler] subscribeNext:^(NSArray *destinations) {
        NSLog(@"Destinations = %@", destinations);
        self.destinations = destinations;
    } completed:^{
        NSLog(@"Reload!");
        [self.tableView reloadData];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBCity *city = self.destinations[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CityCell" forIndexPath: indexPath];
    cell.textLabel.text = city.fullname;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.destinations.count;
}

@end
