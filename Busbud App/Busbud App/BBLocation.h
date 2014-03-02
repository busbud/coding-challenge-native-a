//
//  BBLocation.h
//  Busbud App
//
//  Created by Dan Greencorn on 3/1/2014.
//  Copyright (c) 2014 Dan Greencorn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBLocation : NSObject

@property(nonatomic) NSString *fullname;
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *urlform;

-(id)initWithName:(NSString*)aName fullname:(NSString*)aFullname urlform:(NSString*)aUrlform;

@end
