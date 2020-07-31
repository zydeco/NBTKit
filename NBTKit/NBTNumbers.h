//
//  NBTNumbers.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 29/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// initializer macros for NBT Numbers
#define NBTByte(n)  [[NBTByte alloc] initWithChar:n]
#define NBTShort(n) [[NBTShort alloc] initWithShort:n]
#define NBTInt(n)   [[NBTInt alloc] initWithInt:n]
#define NBTLong(n)  [[NBTLong alloc] initWithLongLong:n]
#define NBTFloat(n) [[NBTFloat alloc] initWithFloat:n]
#define NBTDouble(n)[[NBTDouble alloc] initWithDouble:n]

/** @class NBTByte
 * Represents a NBT byte value (8-bit integer), preserving the type it was created with.
 * Created with NBTByte(value) macro
 */
@interface NBTByte : NSNumber
@end

/** @class NBTShort
 * Represents a NBT short value (16-bit integer), preserving the type it was created with.
 * Created with NBTShort(value) macro
 */
@interface NBTShort : NSNumber
@end

/** @class NBTInt
 * Represents a NBT int value (32-bit integer), preserving the type it was created with.
 * Created with NBTInt(value) macro
 */
@interface NBTInt : NSNumber
@end

/** @class NBTLong
 * Represents a NBT long value (64-bit integer), preserving the type it was created with.
 * Created with NBTLong(value) macro
 */
@interface NBTLong : NSNumber
@end

/** @class NBTFloat
 * Represents a NBT float value (32-bit float), preserving the type it was created with.
 * Created with NBTFloat(value) macro
 */
@interface NBTFloat : NSNumber
@end

/** @class NBTDouble
 * Represents a NBT double value (64-bit float), preserving the type it was created with.
 * Created with NBTDouble(value) macro
 */
@interface NBTDouble : NSNumber
@end

NS_ASSUME_NONNULL_END
