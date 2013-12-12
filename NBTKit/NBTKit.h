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

typedef NS_ENUM(NSUInteger, NBTOptions) {
    /// Read or write little endian NBT data (used by Minecraft Pocket Edition)
    NBTLittleEndian =   1 << 0,
    /// Read gzip or zlib, write gzip (used in compressed NBT files)
    NBTCompressed =     1 << 1,
    /// Used for writing chunks within region files (combine this flag with NBTCompressed)
    NBTUseZlib =        1 << 2,
};

@interface NBTKit : NSObject

/**
 * Returns a mutable dictionary with the root tag from given NBT file.
 *
 * NBT objects are mapped to their corresponding Foundation objects.
 *
 * @param data The NBT data to read.
 * @param name Upon return contains the name of the root tag. Pass NULL if not needed.
 * @param opt A combination of NBTOptions or zero. Valid options for reading are NBTCompressed and NBTLittleEndian
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 *
 * @return A NSMutableDictionary with the root tag, or nil if an error occurs.
 */
+ (NSMutableDictionary*)NBTWithData:(NSData *)data name:(NSString **)name options:(NBTOptions)opt error:(NSError **)error;

/**
 * Returns a mutable dictionary with the root tag from given NBT file.
 *
 * NBT objects are mapped to their corresponding Foundation objects.
 *
 * @param path Path to the NBT file to read.
 * @param name Upon return contains the name of the root tag. Pass NULL if not needed.
 * @param opt A combination of NBTOptions or zero. Valid options for reading are NBTCompressed and NBTLittleEndian
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 *
 * @return A NSMutableDictionary with the root tag, or nil if an error occurs.
 */
+ (NSMutableDictionary*)NBTWithFile:(NSString *)path name:(NSString **)name options:(NBTOptions)opt error:(NSError **)error;

/**
 * Returns a mutable dictionary with the root tag from given NBT file.
 *
 * NBT objects are mapped to their corresponding Foundation objects.
 *
 * @param stream Stream to read from.
 * @param name Upon return contains the name of the root tag. Pass NULL if not needed.
 * @param opt A combination of NBTOptions or zero. Valid options for reading are NBTCompressed and NBTLittleEndian
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 *
 * @return A NSMutableDictionary with the root tag, or nil if an error occurs.
 */
+ (NSMutableDictionary*)NBTWithStream:(NSInputStream *)stream name:(NSString **)name options:(NBTOptions)opt error:(NSError **)error;

/**
 * Returns NBT data from a NSDictionary
 *
 * @param base Root tag.
 * @param name Name of the root tag, or nil for no name.
 * @param opt A combination of NBTOptions or zero. To write with Zlib compression, you must use both NBTCompressed and NBTUseZlib options.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * @return NSData object with the written data
 */
+ (NSData *)dataWithNBT:(NSDictionary*)base name:(NSString*)name options:(NBTOptions)opt error:(NSError **)error;

/**
 * Returns NBT data from a NSDictionary
 *
 * @param base Root tag.
 * @param name Name of the root tag, or nil for no name.
 * @param stream Destination for the NBT data.
 * @param opt A combination of NBTOptions or zero. To write with Zlib compression, you must use both NBTCompressed and NBTUseZlib options.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * @return Number of bytes written, 0 on failure
 */
+ (NSInteger)writeNBT:(NSDictionary*)base name:(NSString*)name toStream:(NSOutputStream *)stream options:(NBTOptions)opt error:(NSError **)error;

/**
 * Returns NBT data from a NSDictionary
 *
 * @param base Root tag.
 * @param name Name of the root tag, or nil for no name.
 * @param path Destination for the NBT data.
 * @param opt A combination of NBTOptions or zero. To write with Zlib compression, you must use both NBTCompressed and NBTUseZlib options.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * @return Number of bytes written, 0 on failure
 */
+ (NSInteger)writeNBT:(NSDictionary*)base name:(NSString*)name toFile:(NSString *)path options:(NBTOptions)opt error:(NSError **)error;

/**
 * Returns a Boolean value that indicates whether a given object can be converted to NBT data.
 *
 * Valid objects are: NSDictionary, NSArray, NSString, NSData, NBTIntArray, NBTByte, NBTShort, NBTInt, NBTLong, NBTFloat, NBTDouble
 *
 * @param obj Object to check
 * @return YES if obj can be converted to JSON data, otherwise NO.
 */
+ (BOOL)isValidNBTObject:(id)obj;

@end
