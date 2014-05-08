//
//  NSFileManager+TPFileUtils.h
//  Pods
//
//  Created by Kerem Karatal on 4/29/14.
//
//

#import <Foundation/Foundation.h>

@interface NSFileManager (TPFileUtils)
- (void) enumerateFilesInFolder:(NSString *) folderPath
               filterByFilename:(NSString *) filename
                     usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop)) enumerateBlock;
@end
