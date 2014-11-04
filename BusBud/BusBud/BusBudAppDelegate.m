//
//  AppDelegate.m
//  BusBud
//
//  Created by Chris Comeau on 2014-11-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import "BusBudAppDelegate.h"

@interface BusBudAppDelegate ()
@property (nonatomic, assign) BOOL updatingLocation;
@property (nonatomic, assign) BOOL firstTimeUpdatingLocation;

@end

@implementation BusBudAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //location
    self.updatingLocation = NO;
    self.firstTimeUpdatingLocation = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    //for ios8
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    //status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


#pragma mark - Location

-(void)startUpdatingLocation
{
    if(!self.updatingLocation) {
        self.updatingLocation = YES;
        self.firstTimeUpdatingLocation = YES;
        [self.locationManager startUpdatingLocation];
    }
}

-(void)stopUpdatingLocation
{
    if(self.updatingLocation) {
        self.updatingLocation = NO;
        self.firstTimeUpdatingLocation = NO;
        [self.locationManager stopUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if(!locations || locations.count ==0)
        return;
    
    //Always ignore the first location update because it is almost always cached.
    //http://www.raywenderlich.com/55386/ios-7-best-practices-part-2
    if(self.firstTimeUpdatingLocation) {
        self.firstTimeUpdatingLocation = NO;
        return;
    }
    
    CLLocation *newLocation = [locations lastObject];
    // post notification that a new location has been found
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewLocationNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:newLocation forKey:kNewLocationKey]];
    
    
    //accurate enough
    if (newLocation.horizontalAccuracy > 0) {
        [self stopUpdatingLocation];
    }
    
    
    //[manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (BOOL)isLocationAvailable
{
    //system level
    if(![CLLocationManager locationServicesEnabled])
        return NO;
    
    //app level
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied)
        return NO;
    return YES;
}

-(float) getLatitude {
    float latitude = kAppDelegate.locationManager.location.coordinate.latitude;
    return latitude;
}

-(float) getLongitude {
    float longitude = kAppDelegate.locationManager.location.coordinate.longitude;
    return longitude;
}


-(BOOL) isValidLatitude:(float)latitude andLongitude:(float)longitude {
    return(! ([self doublesEqual:latitude second:0.0f] && [self doublesEqual:longitude second:0.0f] ));
}

#pragma mark -  Math

-(BOOL)doublesEqual:(double)first second:(double)second value:(double)value {
    BOOL equal = NO;
    
    if ( fabs( first - second) < value )
        equal = YES;
    
    return equal;
}

-(BOOL)doublesEqual:(double)first second:(double)second {
    
    return [self doublesEqual:first second:second value:DBL_EPSILON2];
}

@end
