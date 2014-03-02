//
//  BBWebViewController.h
//  Busbud App
//
//  Created by Dan Greencorn on 3/1/2014.
//  Copyright (c) 2014 Dan Greencorn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBViewController.h"

@interface BBWebViewController : BBViewController

// UI Outlets
@property(nonatomic) IBOutlet UIWebView *webView;

// Data properties
@property(nonatomic) NSString *url;


@end
