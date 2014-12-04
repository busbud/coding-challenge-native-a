//
//  AppDelegate.h
//  BusBud
//
//  Created by Chris Comeau on 2014-11-02.
//  Copyright (c) 2014 Skyriser Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kAppDelegate ((BusBudAppDelegate *)[[UIApplication sharedApplication] delegate])

typedef enum
{
    SearchTypeFrom = 0,
    SearchTypeTo = 1
} SearchType;

@interface BusBudAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *apiToken;

//location
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (BOOL)isLocationAvailable;
-(BOOL) isValidLatitude:(float)latitude andLongitude:(float)longitude;
-(float) getLatitude;
-(float) getLongitude;

//math
-(BOOL)doublesEqual:(double)first second:(double)second;

@end

