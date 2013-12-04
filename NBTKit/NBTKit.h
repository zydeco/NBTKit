//
//  NBTKit.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 29/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBTNumbers.h"
#import "NBTIntArray.h"
#import "MCRegion.h"

extern NSString *NBTKitErrorDomain;

typedef NS_ENUM(NSInteger, NBTKitError) {
    NBTErrorGeneral = 0,
    NBTInvalidArgError,
    NBTReadError,
    NBTWriteError,
    NBTTypeError
};

// NBT read/write options
typedef NS_ENUM(NSUInteger, NBTOptions) {
    NBTLittleEndian =   1 << 0,
    NBTCompressed =     1 << 1, // read gzip or zlib, write gzip (used in compressed nbt files)
    NBTUseZlib =        1 << 2, // used in chunks within region files (combine this flag with NBTCompressed)
};

@interface NBTKit : NSObject

// reading
+ (NSMutableDictionary*)NBTWithData:(NSData *)data name:(NSString **)name options:(NBTOptions)opt error:(NSError **)error;
+ (NSMutableDictionary*)NBTWithFile:(NSString *)path name:(NSString **)name options:(NBTOptions)opt error:(NSError **)error;
+ (NSMutableDictionary*)NBTWithStream:(NSInputStream *)stream name:(NSString **)name options:(NBTOptions)opt error:(NSError **)error;

// writing
+ (NSData *)dataWithNBT:(NSDictionary*)base name:(NSString*)name options:(NBTOptions)opt error:(NSError **)error;
+ (NSInteger)writeNBT:(NSDictionary*)base name:(NSString*)name toStream:(NSOutputStream *)stream options:(NBTOptions)opt error:(NSError **)error;
+ (NSInteger)writeNBT:(NSDictionary*)base name:(NSString*)name toFile:(NSString *)path options:(NBTOptions)opt error:(NSError **)error;
+ (BOOL)isValidNBTObject:(id)obj;

@end
