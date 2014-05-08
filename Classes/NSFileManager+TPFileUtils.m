//
//  NSFileManager+TPFileUtils.m
//  Pods
//
//  Created by Kerem Karatal on 4/29/14.
//
//

#import "NSFileManager+TPFileUtils.h"

@implementation NSFileManager (TPFileUtils)

- (void) enumerateFilesInFolder:(NSString *) foldername
               filterByFilename:(NSString *) filename
                     usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop)) enumerateBlock {
  
  NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
  NSString *userFolderPath = [rootPath stringByAppendingPathComponent:foldername];
  
  NSDirectoryEnumerator *dirEnum = [self enumeratorAtPath:userFolderPath];  
  NSString *file;
  NSUInteger idx = 0;
  BOOL stop = NO;
  while ((file = [dirEnum nextObject]) && !stop) {
    NSArray *pathComponents = [file pathComponents];
    NSString *filename = [pathComponents objectAtIndex:[pathComponents count] - 1];
    NSArray *filenameComponents = [filename componentsSeparatedByString:@"-"];
    if (filenameComponents && [filenameComponents count] == 2){
      if ([filenameComponents[0] isEqualToString:filename]) {
        enumerateBlock(file, idx, &stop);
        idx += 1;
      }
    }
  }
}

@end
