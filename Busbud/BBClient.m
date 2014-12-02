//
//  BBClient.m
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-27.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import "BBClient.h"
#import "BBCity.h"

#import <FXKeychain/FXKeychain.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Mantle/Mantle.h>

@import CoreLocation;

NSString * const BBClientTokenKey = @"BBClientToken";
NSString * const BBClientErrorDomain = @"BBClientErrorDomain";

@interface BBClient ()

@property (nonatomic, strong) NSURL *endpoint;
@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, strong) FXKeychain *keychain;

@end

@implementation BBClient

- (instancetype)initWithEndpoint:(NSURL *)endpoint locale:(NSLocale *)locale keychain:(FXKeychain *)keychain {
    self = [super init];
    if (self) {
        _endpoint = endpoint;
        _locale = locale;
        _keychain = keychain;
    }
    
    return self;
}

- (RACSignal *)fetchToken {
    if (self.keychain) {
        NSString *token = [self.keychain objectForKey: BBClientTokenKey];
        if (token) {
            return [RACSignal return: token];
        }
    }
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *tokenUrl = [self.endpoint URLByAppendingPathComponent: @"/auth/guest"];
        
        NSURLSession *session = NSURLSession.sharedSession;
        NSURLSessionTask *task = [session dataTaskWithURL: tokenUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [subscriber sendError: error];
                return;
            }
            
            NSError *payloadError = nil;
            NSDictionary *payload = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &payloadError];
            if (payloadError) {
                [subscriber sendError: payloadError];
                return;
            }
            
            if (![payload[@"success"] boolValue]) {
                [subscriber sendError: [NSError errorWithDomain: BBClientErrorDomain code: BBClientInteralError userInfo: nil]];
            }
            
            [subscriber sendNext: payload[@"token"]];
            [subscriber sendCompleted];
        }];
        
        [task resume];
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] doNext:^(NSString *token) {
        NSLog(@"Storing token %@", token);
        if (self.keychain) {
            BOOL stored = [self.keychain setObject: token forKey: BBClientTokenKey];
            NSLog(@"Stored token : %@", stored ? @"YES" : @"NO");
        }
    }];
}

- (RACSignal *)search:(NSString *)prefix around:(CLLocation *)location origin:(BBCity *)originCity {
    return [[[[self fetchToken] flattenMap:^RACStream *(NSString *token) {
        NSLog(@"Got token %@", token);
        
        return [RACSignal createSignal: ^RACDisposable *(id<RACSubscriber> subscriber) {
            NSURLComponents *components = [[NSURLComponents alloc] initWithURL: self.endpoint resolvingAgainstBaseURL: YES];
            components.path = @"/search";
            components.query = [NSString stringWithFormat: @"lang=%@&limit=%d&lat=%f&lon=%f&origin_id=%@", prefix, 5, location.coordinate.latitude, location.coordinate.longitude, originCity ? originCity.identifier : @""];
            NSLog(@"Final url = %@", components.URL);
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: components.URL];
            [request setValue: token forHTTPHeaderField: @"X-Busbud-Token"];
            
            NSURLSessionTask *task = [NSURLSession.sharedSession dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    [subscriber sendError: error];
                    return;
                }
                
                NSError *payloadError;
                NSArray *cities = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &payloadError];
                
                if (payloadError) {
                    [subscriber sendError: payloadError];
                    return;
                }
                
                [cities enumerateObjectsUsingBlock:^(NSDictionary *cityPayload, NSUInteger idx, BOOL *stop) {
                    [subscriber sendNext: cityPayload];
                }];
                [subscriber sendCompleted];
            }];
            
            [task resume];
            
            return [RACDisposable disposableWithBlock:^{
                [task cancel];
            }];
        }];
    }] map:^id(NSDictionary *payload) {
        NSError *mappingError;
        
        BBCity *city = [MTLJSONAdapter modelOfClass: BBCity.class fromJSONDictionary: payload error: &mappingError];
        if (mappingError) {
            return mappingError;
        }
        
        return city;
    }] flattenMap:^RACStream *(id value) {
        if ([value isKindOfClass: NSError.class]) {
            return [RACSignal error: value];
        }
        
        return [RACSignal return: value];
    }];
}

@end
