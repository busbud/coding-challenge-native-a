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
    RAC(self.originCityField, text) = [RACObserve(self, origin) map:^id(BBCity *city) {
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
    [[[[[searchSignal deliverOn: RACScheduler.mainThreadScheduler] map:^id(NSArray *results) {
        return results.firstObject;
    }] doNext: ^(BBCity *originCity) {
        self.origin = originCity;
    }] flattenMap:^RACStream *(BBCity *originCity) {
        return [[self.client search: nil around: nil origin: originCity] collect];
    }] subscribeNext:^(NSArray *destinations) {
        NSLog(@"Destinations = %@", destinations);
        self.destinations = destinations;
    } completed:^{
        NSLog(@"Reload!");
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
