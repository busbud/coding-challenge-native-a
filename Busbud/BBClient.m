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
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation BBClient

- (instancetype)initWithEndpoint:(NSURL *)endpoint locale:(NSLocale *)locale keychain:(FXKeychain *)keychain {
    self = [super init];
    if (self) {
        _endpoint = endpoint;
        _locale = locale;
        _keychain = keychain;
        _session = [NSURLSession sessionWithConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration];
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
        
        NSURLSessionTask *task = [self.session dataTaskWithURL: tokenUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject: @5 forKey: @"limit"];
            if (prefix) {
                parameters[@"q"] = prefix;
            }
            
            if (location) {
                parameters[@"lat"] = @(location.coordinate.latitude);
                parameters[@"lon"] = @(location.coordinate.longitude);
            }
            
            if (originCity) {
                parameters[@"origin_id"] = originCity.identifier;
            }
            
            NSURL *searchUrl = [self createURLForEndpoint: @"search" parameters: parameters];
            NSLog(@"Final url = %@", searchUrl);
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: searchUrl];
            [request setValue: token forHTTPHeaderField: @"X-Busbud-Token"];
            
            NSURLSessionTask *task = [self.session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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

- (NSURL *)createURLForEndpoint:(NSString *)endpoint parameters:(NSDictionary *)parameters {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL: self.endpoint resolvingAgainstBaseURL: YES];
    
    if (![[endpoint substringWithRange:(NSRange){0, 1}] isEqualToString: @"/"]) {
        endpoint = [@"/" stringByAppendingString: endpoint];
    }
    components.path = endpoint;

    NSString *lang = [self.locale objectForKey: NSLocaleLanguageCode];
    NSMutableString *query = [NSMutableString stringWithFormat: @"lang=%@", lang];
    [parameters.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        [query appendFormat: @"&%@=%@", key, parameters[key]];
    }];
    components.query = query;
    
    return components.URL;
}

@end
