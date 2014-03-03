//
//  BBCurrentLocationViewController.h
//  Busbud App
//
//  Created by Dan Greencorn on 3/3/2014.
//  Copyright (c) 2014 Dan Greencorn. All rights reserved.
//

#import "BBViewController.h"
#import <CoreLocation/CoreLocation.h>
@class BBLocation;

@interface BBCurrentLocationViewController : BBViewController <CLLocationManagerDelegate,NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    
    @private
    CLLocationManager *locationManager;
}

@property(nonatomic) IBOutlet UIButton *findRouteButton;
@property(nonatomic) IBOutlet UILabel *loadingLabel;
@property(nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property(nonatomic) BBLocation *currentBBLocation;
@property(nonatomic) CLLocation *currentLocation;

@end
