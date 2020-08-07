//
//  NBTReader.m
//  NBTKit
//
//  Created by Jesús A. Álvarez on 29/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import "NBTReader.h"
#import "NBTKit.h"
#import "NBTKit_Private.h"
#import "NBTNumbers.h"

@implementation NBTReader
{
    NSInputStream *stream;
}

- (instancetype)initWithStream:(NSInputStream *)aStream
{
    if ((self = [super init])) {
        stream = aStream;
        [stream open];
    }
    return self;
}

- (void)dealloc
{
    [stream close];
}

- (id)readRootTag:(NSString *__autoreleasing *)name error:(NSError *__autoreleasing *)error
{
    @try {
        return [self readNamedTag:name];
    }
    @catch (NSException *exception) {
        if (error) *error = [NBTKit _errorFromException:exception];
        return nil;
    }
}

- (id)readNamedTag:(NSString *__autoreleasing *)name
{
    // read tag
    uint8_t tag = [self readByte];
    if (tag == NBT_End) return [NSNull null];
    
    // read name
    NSString *tagName = [self readString];
    if (name) *name = tagName;
    
    // read payload
    return [self readTagOfType:tag];
}

- (id)readTagOfType:(NBTType)type
{
    if (type == NBT_Byte) {
        return NBTByte([self readByte]);
    } else if (type == NBT_Short) {
        return NBTShort([self readShort]);
    } else if (type == NBT_Int) {
        return NBTInt([self readInt]);
    } else if (type == NBT_Long) {
        return NBTLong([self readLong]);
    } else if (type == NBT_Float) {
        return NBTFloat([self readFloat]);
    } else if (type == NBT_Double) {
        return NBTDouble([self readDouble]);
    } else if (type == NBT_Byte_Array) {
        return [self readByteArray];
    } else if (type == NBT_String) {
        return [self readString];
    } else if (type == NBT_List) {
        return [self readList];
    } else if (type == NBT_Compound) {
        return [self readCompound];
    } else if (type == NBT_Int_Array) {
        return [self readIntArray];
    } else if (type == NBT_Long_Array) {
        return [self readLongArray];
    }
    
    @throw [NSException exceptionWithName:@"NBTTypeException" reason:[NSString stringWithFormat:@"Don't know how to read tag of type %d", type] userInfo:@{@"tag": @(type)}];
}

- (void)readError
{
    NSMutableDictionary *userInfo = @{
        NSLocalizedFailureReasonErrorKey: @"Error reading NBT."
    }.mutableCopy;
    if ([stream propertyForKey:NSStreamFileCurrentOffsetKey]) {
        userInfo[NSStreamFileCurrentOffsetKey] = [stream propertyForKey:NSStreamFileCurrentOffsetKey];
    }
    if (stream.streamError) {
        userInfo[@"error"] = stream.streamError;
    }
    @throw [NSException exceptionWithName:@"NBTReadException" reason:stream.streamError.description ?: @"Error reading NBT." userInfo:userInfo];
}

#pragma mark Basic type reading

- (int8_t)readByte
{
    uint8_t buf[1];
    if ([stream read:buf maxLength:sizeof buf] != sizeof buf) [self readError];
    return buf[0];
}

- (int16_t)readShort
{
    uint8_t buf[2];
    if ([stream read:buf maxLength:sizeof buf] != sizeof buf) [self readError];
    return _littleEndian ? OSReadLittleInt16(buf, 0) : OSReadBigInt16(buf, 0);
}

- (int32_t)readInt
{
    uint8_t buf[4];
    if ([stream read:buf maxLength:sizeof buf] != sizeof buf) [self readError];
    return _littleEndian ? OSReadLittleInt32(buf, 0) : OSReadBigInt32(buf, 0);
}

- (int64_t)readLong
{
    uint8_t buf[8];
    if ([stream read:buf maxLength:sizeof buf] != sizeof buf) [self readError];
    return _littleEndian ? OSReadLittleInt64(buf, 0) : OSReadBigInt64(buf, 0);
}

- (float)readFloat
{
    int32_t val = [self readInt];
    return *(float*)&val;
}

- (double)readDouble
{
    int64_t val = [self readLong];
    return *(double*)&val;
}

#pragma mark - Compound type reading

- (NSMutableData*)readByteArray
{
    // length
    int32_t len = [self readInt];
    if (len < 0) [self readError];
    
    // data
    NSMutableData *data = [NSMutableData dataWithLength:len];
    if ([stream read:data.mutableBytes maxLength:data.length] != data.length) [self readError];
    
    return data;
}

- (NSString*)readString
{
    // length
    int16_t len = [self readShort];
    if (len == 0) return @"";
    if (len < 0) [self readError];
    
    // data
    uint8_t *buf = malloc(len);
    if ([stream read:buf maxLength:len] != len) [self readError];
    
    return [[NSString alloc] initWithBytesNoCopy:buf length:len encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

- (NSMutableArray*)readList
{
    // type
    int8_t tag = [self readByte];
    
    // length
    int32_t len = [self readInt];
    if (len < 0) [self readError];
    
    // items
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:len];
    while (len--) {
        [list addObject:[self readTagOfType:tag]];
    }
    
    return list;
}

- (NSMutableDictionary*)readCompound
{
    NSMutableDictionary *compound = [NSMutableDictionary new];
    
    for (;;) {
        NSString *name = nil;
        id obj = [self readNamedTag:&name];
        if (obj == [NSNull null]) break;
        compound[name] = obj;
    }
    
    return compound;
}

- (NBTIntArray*)readIntArray
{
    int32_t len = [self readInt];
    if (len < 0) [self readError];
    NBTIntArray *intArray = [NBTIntArray intArrayWithCount:len];
    int32_t *values = intArray.values;
    while (len--) {
        *values++ = [self readInt];
    }
    
    return intArray;
}

- (NBTLongArray*)readLongArray
{
    int32_t len = [self readInt];
    if (len < 0) [self readError];
    NBTLongArray *longArray = [NBTLongArray longArrayWithCount:len];
    int64_t *values = longArray.values;
    while (len--) {
        *values++ = [self readLong];
    }
    
    return longArray;
}

@end
