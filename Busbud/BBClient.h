//
//  BBClient.h
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-27.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FXKeychain;
@class RACSignal;

extern NSString * const BBClientTokenKey;
extern NSString * const BBClientErrorDomain;

typedef NS_ENUM(NSUInteger, BBClientError) {
    BBClientInteralError = 1
};

@interface BBClient : NSObject

- (instancetype)initWithEndpoint:(NSURL *)endpoint locale:(NSLocale *)locale keychain:(FXKeychain *)keychain;

- (RACSignal *)fetchToken;

@end
