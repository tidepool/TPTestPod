//
//  TPSettings.h
//  Pods
//
//  Created by Kerem Karatal on 1/30/14.
//
//

#import <Foundation/Foundation.h>
#import "TPCommon.h"

@interface TPSettings : NSObject
+ (NSDictionary *) loadSettings;
+ (NSDateFormatter *) dateFormatter;
+ (NSDateFormatter *) dateOnlyFormatter;
+ (NSString *) filePathForFilename:(NSString *) filename;
+ (NSString *) filePathForFilename:(NSString *)filename folderName:(NSString *) folderName;
+ (NSDictionary *) dictionaryFromPageInfo:(TPPageInfo) pageInfo;
+ (TPPageInfo) pageInfoFromDictionary:(NSDictionary *) dict;
@end
