//
//  NBTNumbers.m
//  NBTKit
//
//  Created by Jesús A. Álvarez on 29/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import "NBTNumbers.h"
#import "NBTKit_Private.h"

#define NSNUMBER_SUBCLASS(name, ctype, initWithX, xValue) \
@implementation name \
{ ctype _value; }    \
- (instancetype)initWithX:(ctype)value { return [self initWithBytes:&value objCType:@encode(ctype)]; } \
- (ctype)xValue { return _value; } \
- (instancetype)initWithBytes:(const void *)value objCType:(const char *)type { \
    if (strcmp(@encode(ctype), type)) @throw [NSException exceptionWithName:@"NBTTypeException" reason:[NSString stringWithFormat:@"%@ can only be initialized with objCType %s (not %s)", NSStringFromClass([self class]), @encode(ctype), type] userInfo:nil]; \
    if ((self = [super init])) {_value = *(ctype*)value;} \
    return self; } \
+ (NSValue *)valueWithBytes:(const void *)value objCType:(const char *)type {return [[self alloc] initWithBytes:value objCType:type];} \
+ (NSValue *)value:(const void *)value withObjCType:(const char *)type { return [self valueWithBytes:value objCType:type]; } \
- (void)getValue:(void *)value { *(ctype*)value = _value; } \
- (const char *)objCType NS_RETURNS_INNER_POINTER { return @encode(ctype);} \
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

NSNUMBER_SUBCLASS(NBTByte, char, initWithChar, charValue)
NSNUMBER_SUBCLASS(NBTShort, int16_t, initWithShort, shortValue)
NSNUMBER_SUBCLASS(NBTInt, int32_t, initWithInt, intValue)
NSNUMBER_SUBCLASS(NBTLong, int64_t, initWithLongLong, longLongValue)
NSNUMBER_SUBCLASS(NBTFloat, float, initWithFloat, floatValue)
NSNUMBER_SUBCLASS(NBTDouble, double, initWithDouble, doubleValue)

#pragma clang diagnostic pop
