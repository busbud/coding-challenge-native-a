//
//  SearchTableViewController.m
//  Busbud
//
//  Created by Romain Pouclet on 2014-12-09.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import "SearchTableViewController.h"
#import "BBClient.h"
#import "BBCity.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface SearchTableViewController ()

@property (nonatomic, copy) NSArray *cities;
@property (nonatomic, weak) BBClient *client;

@end

@implementation SearchTableViewController

- (instancetype)initWithClient:(BBClient *)client {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
        _client = client;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass: UITableViewCell.class forCellReuseIdentifier: @"CityResultCell"];
}

- (void)updateWithSearchResultsFor:(NSString *)prefix {
    NSLog(@"updateWithSearchResultsFor %@", prefix);

    RACSignal *search = [[[self.client search: prefix around: nil origin: nil] collect] deliverOn: RACScheduler.mainThreadScheduler];
    
    @weakify(self);
    [search subscribeNext:^(NSArray *cities) {
        @strongify(self);
        NSLog(@"Cities = %@", cities);
        self.cities = cities;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"Got error = %@", error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBCity *city = self.cities[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CityResultCell" forIndexPath:indexPath];
    cell.textLabel.text = city.fullname;
    NSLog(@"Returning cell");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.searchDelegate respondsToSelector: @selector(searchTableViewController:didSelectCity:)]) {
        [self.searchDelegate searchTableViewController: self didSelectCity: self.cities[indexPath.row]];
    }
}

@end
