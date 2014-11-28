//
//  BBCity.m
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-27.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import "BBCity.h"

@implementation BBCity

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"identifier": @"city_id", @"url" : @"url", @"fullname" : @"full_name"};
}

@end
