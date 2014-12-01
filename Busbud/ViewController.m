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
#import <ReactiveCocoa/RACEXTScope.h>

@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) BBClient *client;
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) BBCity *origin;

@end

@implementation ViewController

- (void)viewDidLoad {
    self.client = [[BBClient alloc] initWithEndpoint: [NSURL URLWithString: @"https://busbud-napi-prod.global.ssl.fastly.net"]
                                              locale: NSLocale.currentLocale
                                            keychain: [FXKeychain defaultKeychain]];
    

    RAC(self, title) = [RACObserve(self, origin) map:^id(BBCity *city) {
        NSLog(@"Chaging title to %@", city.fullname);
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
    
    @weakify(self);
    [[[self.client search: nil around: locations.lastObject origin: nil] collect] subscribeNext:^(NSArray *suggestions) {
        @strongify(self);
        self.origin = suggestions.firstObject;
    }];
}

@end
