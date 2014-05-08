//
//  TPSettings.m
//  Pods
//
//  Created by Kerem Karatal on 1/30/14.
//
//

#import "TPSettings.h"

//#define LOCAL_SERVER 1
//#define TEST_SERVER 1
#define PRODUCTION_SERVER 1

@implementation TPSettings

+ (NSDictionary *) loadSettings {
  NSString *resourceFilename = @"settings";
#ifdef LOCAL_SERVER
  resourceFilename = @"settings_local";
#endif
#ifdef TEST_SERVER
  resourceFilename = @"settings_test";
#endif
#ifdef PRODUCTION_SERVER
  resourceFilename = @"settings_production";
#endif
  NSLog(@"Resource File Name: %@", resourceFilename);
  NSString *filePath = [[NSBundle bundleForClass: [TPSettings class]] pathForResource:resourceFilename ofType:@"plist"];
  NSData *pListData = [NSData dataWithContentsOfFile:filePath];
  NSPropertyListFormat format;
  NSString *error;
  NSDictionary *settings = (NSDictionary *) [NSPropertyListSerialization propertyListFromData:pListData
                                                                             mutabilityOption:NSPropertyListImmutable
                                                                                       format:&format
                                                                             errorDescription:&error];
  
  return settings;
}

+ (NSDateFormatter *) dateFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";
  return formatter;
}

+ (NSDateFormatter *) dateOnlyFormatter {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  formatter.dateFormat = @"yyyy-MM-dd";
  return formatter;
}

+ (NSString *) filePathForFilename:(NSString *) filename {
  NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *filePath = [rootPath stringByAppendingPathComponent:filename];
  
  return filePath;
}

+ (NSString *) filePathForFilename:(NSString *)filename folderName:(NSString *) folderName {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *userFolderPath = [rootPath stringByAppendingPathComponent:folderName];
  if (![fileManager fileExistsAtPath:userFolderPath]) {
    [fileManager createDirectoryAtPath:userFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
  }
 
  NSString *filePath = [userFolderPath stringByAppendingPathComponent:filename];
  return filePath;
}

+ (NSDictionary *) dictionaryFromPageInfo:(TPPageInfo) pageInfo {
  return @{@"limit": @(pageInfo.limit),
           @"offset": @(pageInfo.offset),
           @"total": @(pageInfo.total),
           @"next_limit": @(pageInfo.nextLimit),
           @"next_offset": @(pageInfo.nextOffset)
           };
}

+ (TPPageInfo) pageInfoFromDictionary:(NSDictionary *) dict {
  TPPageInfo pageInfo;
  pageInfo.limit = [[dict objectForKey:@"limit"] integerValue];
  pageInfo.offset = [[dict objectForKey:@"offset"] integerValue];
  pageInfo.total = [[dict objectForKey:@"total"] integerValue];
  pageInfo.nextLimit = [[dict objectForKey:@"next_limit"] integerValue];
  pageInfo.nextOffset = [[dict objectForKey:@"next_offset"] integerValue];
  
  return pageInfo;
}

@end
