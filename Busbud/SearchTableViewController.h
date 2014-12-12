//
//  SearchTableViewController.h
//  Busbud
//
//  Created by Romain Pouclet on 2014-12-09.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBClient, BBCity;
@class SearchTableViewController;

@protocol SearchTableViewControllerDelegate <NSObject>

- (void)searchTableViewController:(SearchTableViewController *)controller didSelectCity:(BBCity *)city;

@end

@interface SearchTableViewController : UITableViewController

@property (nonatomic, weak) id<SearchTableViewControllerDelegate> searchDelegate;

- (instancetype)initWithClient:(BBClient *)client;
- (void)updateWithSearchResultsFor:(NSString *)prefix;

@end
