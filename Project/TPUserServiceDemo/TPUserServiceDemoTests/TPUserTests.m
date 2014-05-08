//
//  TPUserTests.m
//  TPUserServiceDemo
//
//  Created by Kerem Karatal on 2/4/14.
//  Copyright (c) 2014 TidePool. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TPServices/TPSessionService.h>
#import <TPServices/TPUser.h>
#import "TPTestUtils.h"

static NSString * const kUniqueId = @"unique_id";
static NSString * const kGuest = @"guest";
static NSString * const kPrimaryAccount = @"primary_account";
static NSString * const kAccountId = @"account_id";
static NSString * const kCredentials = @"credentials";
static NSString * const kDisplayName = @"display_name";
static NSString * const kName = @"name";
static NSString * const kImage = @"image";
static NSString * const kEmail = @"email";
static NSString * const kGender = @"gender";
static NSString * const kDateOfBirth = @"date_of_birth";
static NSString * const kAge = @"age";
static NSString * const kEducation = @"education";
static NSString * const kHandedness = @"handedness";
static NSString * const kCity = @"city";
static NSString * const kState = @"state";
static NSString * const kCountry = @"country";
static NSString * const kLocale = @"locale";
static NSString * const kProfilePhoto = @"profile_photo_url";

@interface TPUserTests : XCTestCase
@end

@implementation TPUserTests

#pragma mark - Setup

- (void)setUp {
  [super setUp];
  // Put setup code here; it will be run once, before the first test case.
  [TPTestUtils resetKeyChain];
  [TPTestUtils loginTestUser];
}

- (void)tearDown {
  // Put teardown code here; it will be run once, after the last test case.
  [super tearDown];
  [TPTestUtils resetKeyChain];
}

#pragma mark - Unit Tests

- (void) testInitializingUserWithInvalidDate {
  NSDictionary *input = @{@"date_of_birth": @"foobar"};

  NSError *error;
  TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:input error:&error];

  expect(user.dateOfBirth).to.beNil;
}

- (void) testInitializingUserWithEmptyDate {
  NSDictionary *input = @{@"date_of_birth": @""};
  
  NSError *error;
  TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:input error:&error];

  expect(user.dateOfBirth).to.beNil;
}

- (void) testInitializingUserWithValidDate {
  NSDictionary *input = @{@"date_of_birth": @"2014-02-04T15:20:59.195-08:00"};
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
  NSDate *expectedDate = [formatter dateFromString:[input objectForKey:@"date_of_birth"]];
  
  NSError *error;
  TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:input error:&error];
  expect(user.dateOfBirth).to.equal(expectedDate);
}

- (void) testInitializeUserWithRelativeImageUrl {
  NSDictionary *input = @{kImage: @"foo.jpg"};
  
  TPSessionService *session = [TPSessionService sharedInstance];
  NSString *expectedURLString = [NSString stringWithFormat:@"%@foo.jpg", session.imageBaseURL];
  NSError *error;
  TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:input error:&error];
  expect([[user.imageURL absoluteString] isEqualToString:expectedURLString]).to.beTruthy;
  
  NSDictionary *output = [MTLJSONAdapter JSONDictionaryFromModel:user];
  expect([[output objectForKey:@"image"] isEqualToString:expectedURLString]).to.beTruthy;
}

- (void) testInitalizeUserWithFullImageUrl {
  NSDictionary *input = @{kImage: @"http://example.com/foo.jpg"};
  
  NSError *error;
  TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:input error:&error];
  expect([[user.imageURL absoluteString] isEqualToString:@"http://example.com/foo.jpg"]).to.beTruthy;
  
}

- (void) testReadingAndWritingFormattedAge {
  NSError *error;
  
  TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:@{kAge: @(25)} error:&error];
  expect([user formattedAge]).equal(@"25");

  user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:@{kAge: @(0)} error:&error];
  expect([user formattedAge]).equal(@"N/A");

  [user setAgeFromFormattedAge:@"N/A"];
  expect(user.age).equal(0);
  
  [user setAgeFromFormattedAge:@"35"];
  expect(user.age).equal(35);
}

- (void) testReadingAndWritingFormattedGender {
  NSError *error;
  
  TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:@{kGender: @"female"} error:&error];
  expect([user formattedGender]).equal(1);
  
  user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:@{kGender: @""} error:&error];
  expect([user formattedGender]).equal(2);
  
  [user setGenderFromFormattedGender:0];
  expect([user.gender isEqualToString:@"male"]).to.beTruthy;
  
  [user setGenderFromFormattedGender:2];
  expect([user.gender isEqualToString:@""]).to.beTruthy;
}

- (void) testInitializingUserWithFullData {
  NSDictionary *input = @{kUniqueId: @"12345",
                          kPrimaryAccount: @"facebook",
                          kAccountId: @"123456",
                          kDisplayName: @"foo",
                          kName: @"Foo Bar",
                          kImage: @"http://example.com/image1",
                          kEmail: @"foo@example.com",
                          kGender: @"Male",
                          kAge: @(25),
                          kEducation: @"High School",
                          kHandedness: @"Left",
                          kCity: @"San Francisco",
                          kState: @"CA",
                          kCountry: @"US",
                          kLocale: @"en-us"
                          };
  NSError *error;
  TPUser *user = [MTLJSONAdapter modelOfClass:TPUser.class fromJSONDictionary:input error:&error];
  expect(user.userId).to.equal([input objectForKey:kUniqueId]);
  expect(user.primaryAccount).to.equal([input objectForKey:kPrimaryAccount]);
  expect(user.accountId).to.equal([input objectForKey:kAccountId]);
  expect(user.displayName).to.equal([input objectForKey:kDisplayName]);
  expect(user.gender).to.equal([input objectForKey:kGender]);
  expect(user.age).to.equal([[input objectForKey:kAge] integerValue]);  
}

#pragma mark - Integration - User API

- (void) testUpdateUserData {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];

  __block TPUser *updatedUser = nil;
  __block NSString *errorDesc;

  TPSessionService *session = [TPSessionService sharedInstance];
  TPUser *currentUser = session.user;
  currentUser.name = @"New Name";
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = @"MM-dd-yyyy";
  currentUser.dateOfBirth = [dateFormatter dateFromString:@"05-18-1985"];
  
  [currentUser updateWithSuccess:^(TPUser *user) {
    updatedUser = user;
  } failure:^(NSError *error) {
    errorDesc = [error description];
  }];
  
  expect(updatedUser.name).will.equal(@"New Name");
  expect(updatedUser.dateOfBirth).will.equal(currentUser.dateOfBirth);
}

- (void) testFindLoggedInUser {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];

  [TPTestUtils mockSessionReachabilityWithReachabilityStatus:YES];
  __block TPUser *foundUser = nil;
  __block NSString *errorDesc;
  __block BOOL waitingForResponse = YES;
  [TPUser findLoggedInUserWithSuccess:^(TPUser *user) {
    foundUser = user;
    waitingForResponse = NO;
  } failure:^(NSError *error) {
    errorDesc = [error description];
    waitingForResponse = NO;
  }];
  
  waitUntilFalse(waitingForResponse);
  expect(foundUser.email).will.equal(@"ios_test_user@example.com");
}

- (void) testGetFriends {
  [Expecta setAsynchronousTestTimeout:EXPECTA_TEST_TIMEOUT];
  
  __block NSArray *foundFriends = nil;
  __block TPPageInfo returnedPageInfo;
  __block NSString *errorDesc;
  TPSessionService *session = [TPSessionService sharedInstance];
  TPUser *currentUser = session.user;
  TPPageInfo pageInfo = { 0, 10, 0, 0, 0 };
  
  [currentUser friendsWithPageInfo:pageInfo success:^(NSArray *friends, TPPageInfo pageInfo) {
    foundFriends = friends;
    returnedPageInfo = pageInfo;
  } failure:^(NSError *error) {
    errorDesc = [error description];
  }];
  
  expect([foundFriends count]).will.equal(5);
  expect(returnedPageInfo.total).will.equal(5);
}

@end
