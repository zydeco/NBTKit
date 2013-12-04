//
//  NBTNumbers.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 29/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

// initializer macros for NBT Numbers
#define NBTByte(n)  [[NBTByte alloc] initWithChar:n]
#define NBTShort(n) [[NBTShort alloc] initWithShort:n]
#define NBTInt(n)   [[NBTInt alloc] initWithInt:n]
#define NBTLong(n)  [[NBTLong alloc] initWithLongLong:n]
#define NBTFloat(n) [[NBTFloat alloc] initWithFloat:n]
#define NBTDouble(n)[[NBTDouble alloc] initWithDouble:n]

@interface NBTByte : NSNumber
@end

@interface NBTShort : NSNumber
@end

@interface NBTInt : NSNumber
@end

@interface NBTLong : NSNumber
@end

@interface NBTFloat : NSNumber
@end

@interface NBTDouble : NSNumber
@end
