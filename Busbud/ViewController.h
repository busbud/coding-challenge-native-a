//
//  ViewController.h
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-27.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *originContainer;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

