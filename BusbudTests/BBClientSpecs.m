//
//  BBClientSpecs.m
//  Busbud
//
//  Created by Romain Pouclet on 2014-11-27.
//  Copyright (c) 2014 Romain Pouclet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import <Specta/Specta.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

#import <FXKeychain/FXKeychain.h>
#import "BBClient.h"
#import "BBCity.h"

SpecBegin(BBClient)

describe(@"without a token", ^{
    __block BBClient *client;
    __block BOOL success;
    __block NSError *error;
    __block FXKeychain *keychain;
    __block NSString *token;

    beforeEach(^{
        keychain = OCMClassMock([FXKeychain class]);
        OCMStub([keychain setObject: @"GUEST_q2Q7vXboR9y5onSPr9661g" forKey: BBClientTokenKey]);
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            return [request.URL.path isEqualToString: @"/auth/guest"];
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSString *path = [[NSBundle bundleForClass: self.class] pathForResource: @"token" ofType: @"json"];
            return [OHHTTPStubsResponse responseWithFileAtPath: path
                                                    statusCode: 200
                                                       headers: @{@"Content-Type": @"application/json; charset=utf-8"}];
        }];
        
        client = [[BBClient alloc] initWithEndpoint: [NSURL URLWithString: @"https://busbud-napi-prod.herokuapp.com"]
                                             locale: NSLocale.currentLocale
                                           keychain: keychain];
    });
    
    it(@"should fetch a token and store it", ^{
        RACSignal *tokenSignal = [client fetchToken];
        token = [tokenSignal asynchronousFirstOrDefault: nil success: &success error: &error];
        
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(token).to.equal(@"GUEST_q2Q7vXboR9y5onSPr9661g");
        
        OCMVerify([keychain setObject: @"GUEST_q2Q7vXboR9y5onSPr9661g" forKey: BBClientTokenKey]);
    });
});

describe(@"with a token", ^{
    __block BBClient *client;
    __block BOOL success;
    __block NSError *error;
    __block FXKeychain *keychain;
    __block NSString *token;

    beforeEach(^{
        keychain = OCMClassMock([FXKeychain class]);
        OCMStub([keychain objectForKey: BBClientTokenKey]).andReturn(@"GUESS_my-saved-token");
        
        client = [[BBClient alloc] initWithEndpoint: [NSURL URLWithString: @"https://busbud-napi-prod.herokuapp.com"]
                                             locale: [NSLocale localeWithLocaleIdentifier: @"en_US"]
                                           keychain: keychain];
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            NSString *path = request.URL.path;
            NSString *token = [request valueForHTTPHeaderField: @"X-Busbud-Token"];
            
            return [path isEqualToString: @"/search"] && [token isEqualToString: @"GUESS_my-saved-token"];
        } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
            NSString *path = [[NSBundle bundleForClass: self.class] pathForResource: @"search" ofType: @"json"];
            return [OHHTTPStubsResponse responseWithFileAtPath: path
                                                    statusCode: 200
                                                       headers: @{@"Content-Type": @"application/json; charset=utf-8"}];
        }];
    });
    
    it(@"should reuse the token if available", ^{
        RACSignal *tokenSignal = [client fetchToken];
        token = [tokenSignal asynchronousFirstOrDefault: nil success: &success error: &error];
        
        OCMVerify([keychain objectForKey: BBClientTokenKey]);

        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(token).to.equal(@"GUESS_my-saved-token");
    });

    it(@"should fetch cities around the user", ^{
        RACSignal *searchSignal = [client search: @"Quebec" around: nil origin: nil limit: @5];
        NSArray *cities = [[searchSignal collect] asynchronousFirstOrDefault: nil success: &success error: &error];
        
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        expect(cities.count).to.equal(5);
        
        BBCity *laval = cities[2];
        expect(laval.identifier).to.equal(@"47d4ea85048e645185b005865a098bc5");
        expect(laval.url).to.equal(@"Laval,Quebec,Canada");
        expect(laval.fullname).to.equal(@"Laval, Quebec, Canada");
    });
    
    it(@"should build a proper URL", ^{
        NSDictionary *parameters = @{@"q": @"Mont", @"limit": @5};
        NSURL *searchURL = [client createURLForEndpoint: @"search" parameters: parameters];
        NSURLComponents *components = [NSURLComponents componentsWithURL: searchURL resolvingAgainstBaseURL: NO];
        expect(components.query).to.equal(@"lang=en&q=Mont&limit=5");
    });
});

SpecEnd