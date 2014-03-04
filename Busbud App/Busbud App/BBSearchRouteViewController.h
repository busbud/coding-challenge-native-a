//
//  BBSearchRouteViewController.h
//  Busbud App
//
//  Created by Dan Greencorn on 3/1/2014.
//  Copyright (c) 2014 Dan Greencorn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBViewController.h"

@class BBLocation;

@interface BBSearchRouteViewController : BBViewController <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

// UI outlets
@property(nonatomic) IBOutlet UILabel *departureCityLabel;
@property(nonatomic) IBOutlet UITableView *destinationTableView;

// Data properties
@property(nonatomic) NSMutableArray *destinations;
@property(nonatomic, strong) BBLocation *currentLocation;

@end
