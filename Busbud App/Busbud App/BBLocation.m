//
//  BBLocation.m
//  Busbud App
//
//  Created by Dan Greencorn on 3/1/2014.
//  Copyright (c) 2014 Dan Greencorn. All rights reserved.
//

#import "BBLocation.h"

@implementation BBLocation

@synthesize fullname;
@synthesize name;
@synthesize urlform;

-(id)initWithName:(NSString*)aName fullname:(NSString*)aFullname urlform:(NSString*)aUrlform {
    self = [super init];
    
    if (self) {
        self.name = aName;
        self.fullname = aFullname;
        self.urlform = aUrlform;
    }
    
    return self;
    
}

@end
