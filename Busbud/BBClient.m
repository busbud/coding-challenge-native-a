//
//  BBClient.m
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-27.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import "BBClient.h"
#import <FXKeychain/FXKeychain.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

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
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *tokenUrl = [self.endpoint URLByAppendingPathComponent: @"/auth/guest"];
        
        NSURLSession *session = NSURLSession.sharedSession;
        NSURLSessionTask *task = [session dataTaskWithURL: tokenUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [subscriber sendError: error];
                return;
            }
            
            NSError *mappingError = nil;
            NSDictionary *payload = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &mappingError];
            if (mappingError) {
                [subscriber sendError: error];
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

@end
