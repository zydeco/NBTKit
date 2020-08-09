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
#import "NBTLongArray.h"
#import "MCRegion.h"

/**
* Represents a type of value in a NBT
 */
typedef NS_ENUM(int8_t, NBTType) {
    NBTTypeInvalid = -1,
    NBTTypeEnd,
    NBTTypeByte,
    NBTTypeShort,
    NBTTypeInt,
    NBTTypeLong,
    NBTTypeFloat,
    NBTTypeDouble,
    NBTTypeByteArray,
    NBTTypeString,
    NBTTypeList,
    NBTTypeCompound,
    NBTTypeIntArray,
    NBTTypeLongArray
};

NS_ASSUME_NONNULL_BEGIN

extern NSErrorDomain const NBTKitErrorDomain;

typedef NS_ERROR_ENUM(NBTKitErrorDomain, NBTKitError) {
    NBTErrorGeneral = 0,
    NBTInvalidArgError,
    NBTReadError,
    NBTWriteError,
    NBTTypeError
};

typedef NS_OPTIONS(NSUInteger, NBTOptions) {
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
+ (nullable NSMutableDictionary<NSString*,NSObject*>*)NBTWithData:(NSData *)data name:(NSString *_Nullable *_Nullable)name options:(NBTOptions)opt error:(NSError **)error;

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
+ (nullable NSMutableDictionary<NSString*,NSObject*>*)NBTWithFile:(NSString *)path name:(NSString *_Nullable *_Nullable)name options:(NBTOptions)opt error:(NSError **)error;

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
+ (nullable NSMutableDictionary<NSString*,NSObject*>*)NBTWithStream:(NSInputStream *)stream name:(NSString *_Nullable *_Nullable)name options:(NBTOptions)opt error:(NSError **)error;

/**
 * Returns NBT data from a NSDictionary
 *
 * @param base Root tag.
 * @param name Name of the root tag, or nil for no name.
 * @param opt A combination of NBTOptions or zero. To write with Zlib compression, you must use both NBTCompressed and NBTUseZlib options.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * @return NSData object with the written data
 */
+ (nullable NSData *)dataWithNBT:(NSDictionary*)base name:(nullable NSString*)name options:(NBTOptions)opt error:(NSError **)error;

/**
 * Writes NBT data to a stream
 *
 * @param base Root tag.
 * @param name Name of the root tag, or nil for no name.
 * @param stream Destination for the NBT data.
 * @param opt A combination of NBTOptions or zero. To write with Zlib compression, you must use both NBTCompressed and NBTUseZlib options.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * @return Number of bytes written, 0 on failure
 */
+ (NSInteger)writeNBT:(NSDictionary*)base name:(nullable NSString*)name toStream:(NSOutputStream *)stream options:(NBTOptions)opt error:(NSError **)error;

/**
 * Writes NBT data to a file
 *
 * @param base Root tag.
 * @param name Name of the root tag, or nil for no name.
 * @param path Destination for the NBT data.
 * @param opt A combination of NBTOptions or zero. To write with Zlib compression, you must use both NBTCompressed and NBTUseZlib options.
 * @param error If an error occurs, upon return contains an NSError object that describes the problem.
 * @return Number of bytes written, 0 on failure
 */
+ (NSInteger)writeNBT:(NSDictionary*)base name:(nullable NSString*)name toFile:(NSString *)path options:(NBTOptions)opt error:(NSError **)error;

/**
 * Returns a Boolean value that indicates whether a given object can be converted to NBT data.
 *
 * Valid objects are: NSDictionary, NSArray, NSString, NSData, NBTIntArray, NBTLongArray, NBTByte, NBTShort, NBTInt, NBTLong, NBTFloat, NBTDouble
 *
 * @param obj Object to check
 * @return YES if obj can be converted to NBT data, otherwise NO.
 */
+ (BOOL)isValidNBTObject:(id)obj;

/**
* Returns the Obj-C class used for the given NBTType
*
* @param type NBT tag type
* @returns Corresponding class, or nil if type is invalid.
*/
+ (NBTType)NBTTypeForObject:(nullable id)obj;

/**
 * Returns the Obj-C class used for the given NBTType.
 *
 * @param type NBT tag type
 * @returns Corresponding class, or nil if type is invalid.
 */
+ (nullable Class)classForNBTType:(NBTType)type;

/**
 Returns the name of the given NBTType.
 *
 * @param type NBT tag type
 * @returns Type name
 */
+ (nullable NSString*)nameOfNBTType:(NBTType)type;

@end

@interface NSArray (NBTListType)
/** The list type when the array was read from NBT, otherwise NBTTypeInvaild */
@property (nonatomic, readonly) NBTType nbtListType;
@end

@interface NSDictionary (NBTOrderedKeys)
/** This is guaranteed to always return all keys. */
@property (nonatomic, copy) NSOrderedSet<NSString*>* nbtOrderedKeys;
@end

NS_ASSUME_NONNULL_END
