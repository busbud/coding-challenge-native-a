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

@property (nonatomic, strong) UILabel *originCityLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    self.client = [[BBClient alloc] initWithEndpoint: [NSURL URLWithString: @"https://busbud-napi-prod.global.ssl.fastly.net"]
                                              locale: NSLocale.currentLocale
                                            keychain: [FXKeychain defaultKeychain]];
    
    self.manager = [[CLLocationManager alloc] init];
    [self.manager requestWhenInUseAuthorization];
    self.manager.delegate = self;
    RAC(self, origin) = [[[[[self rac_signalForSelector: @selector(locationManager:didUpdateLocations:)
                       fromProtocol: @protocol(CLLocationManagerDelegate)] map:^id(RACTuple *tuple) {
        return [tuple[1] lastObject];
    }] doNext:^(id x) {
        [self.manager stopUpdatingLocation];
    }] flattenMap:^RACStream *(CLLocation *location) {
        return [[self.client search: nil around: location origin: nil] collect];
    }] map:^id(NSArray *results) {
        return results.lastObject;
    }];
    
    RAC(self.originField, text) = [RACObserve(self, origin) map:^id(BBCity *city) {
        return city.fullname;
    }];
    
    [self.manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Status = %@", @(status));
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failed with error %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"Locations = %@", locations);
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
