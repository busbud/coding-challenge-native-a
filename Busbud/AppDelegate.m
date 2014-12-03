//
//  AppDelegate.m
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-27.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIColor *busbudColor = [UIColor colorWithRed: (CGFloat)18/255
                                           green: (CGFloat)124/255
                                            blue: (CGFloat)203/255
                                           alpha: 1.0];
    [[UINavigationBar appearance] setBarTintColor: busbudColor];
    [[UINavigationBar appearance] setTintColor: UIColor.whiteColor];
    [[UINavigationBar appearance] setShadowImage: [UIImage imageNamed:@"TransparentPixel"]];
    // "Pixel" is a solid white 1x1 image.
    [[UINavigationBar appearance] setBackgroundImage: [UIImage imageNamed:@"Pixel"]
                                       forBarMetrics: UIBarMetricsDefault];
    
    return YES;
}

@end
