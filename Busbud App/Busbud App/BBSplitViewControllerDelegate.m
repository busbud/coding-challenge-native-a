//
//  BBSplitViewControllerDelegate.m
//  Busbud App
//
//  Created by Dan Greencorn on 3/3/2014.
//  Copyright (c) 2014 Dan Greencorn. All rights reserved.
//

#import "BBSplitViewControllerDelegate.h"

@implementation BBSplitViewControllerDelegate


-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

@end
