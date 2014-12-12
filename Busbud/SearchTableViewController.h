//
//  SearchTableViewController.h
//  Busbud
//
//  Created by Romain Pouclet on 2014-12-09.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBClient;

@interface SearchTableViewController : UITableViewController

- (instancetype)initWithClient:(BBClient *)client;
- (void)updateWithSearchResultsFor:(NSString *)prefix;

@end
