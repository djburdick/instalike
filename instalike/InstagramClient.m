//
//  InstagramClient.m
//  Instagram
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "InstagramClient.h"
#import "AFNetworking.h"

#define INSTAGRAM_BASE_URL [NSURL URLWithString:@"https://api.instagram.com/v1/"]
#define INSTAGRAM_CONSUMER_KEY @"biYAqubJD0rK2cRatIQTZw"
#define INSTAGRAM_CONSUMER_SECRET @"2cygl2irBgMQVNuWJwMn6vXiyDnWtht7gSyuRnf0Fg"

static NSString * const kAccessTokenKey = @"kAccessTokenKey";

@implementation InstagramClient

+ (InstagramClient *)instance {
    static dispatch_once_t once;
    static InstagramClient *instance;
    
    dispatch_once(&once, ^{
        instance = [[InstagramClient alloc] initWithBaseURL:INSTAGRAM_BASE_URL clientID:INSTAGRAM_CONSUMER_KEY secret:INSTAGRAM_CONSUMER_SECRET];
    });
    
    return instance;
}

- (id) initWithBaseURL:(NSURL *)url clientID:(NSString *)clientID secret:(NSString *)secret {
    self = [super initWithBaseURL:INSTAGRAM_BASE_URL clientID:INSTAGRAM_CONSUMER_KEY secret:INSTAGRAM_CONSUMER_SECRET];
    
    if (self != nil) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:kAccessTokenKey];
        if (data) {
            self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return self;
}

#pragma mark - Users API

- (void)authorizeWithCallbackUrl:(NSURL *)callbackUrl success:(void (^)(AFOAuthCredential *accessToken, id responseObject))success failure:(void (^)(NSError *error))failure {
    self.accessToken = nil;
    [super authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token" userAuthorizationPath:@"oauth/authorize" callbackURL:callbackUrl accessTokenPath:@"oauth/access_token" accessMethod:@"POST" scope:nil success:success failure:failure];
}

- (void)currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self getPath:@"1.1/account/verify_credentials.json" parameters:nil success:success failure:failure];
}

#pragma mark - Statuses API

- (void)homeTimelineWithCount:(int)count sinceId:(int)sinceId maxId:(int)maxId success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"count": @(count)}];
    if (sinceId > 0) {
        [params setObject:@(sinceId) forKey:@"since_id"];
    }
    if (maxId > 0) {
        [params setObject:@(maxId) forKey:@"max_id"];
    }
    [self getPath:@"1.1/statuses/home_timeline.json" parameters:params success:success failure:failure];
}

#pragma mark - Private methods

- (void)setAccessToken:(AFOAuth2Token *)accessToken {
    [super setAccessToken:accessToken];

    if (accessToken) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAccessTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccessTokenKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
