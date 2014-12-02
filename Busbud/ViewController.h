//
//  ViewController.h
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-27.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *originCityField;
@property (weak, nonatomic) IBOutlet UITextField *destinationCityField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

