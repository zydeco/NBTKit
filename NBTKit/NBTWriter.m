//
//  NBTWriter.m
//  NBTKit
//
//  Created by Jesús A. Álvarez on 30/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import "NBTWriter.h"
#import "NBTKit.h"
#import "NBTKit_Private.h"

@implementation NBTWriter
{
    NSOutputStream *stream;
}

- (instancetype)initWithStream:(NSOutputStream *)aStream
{
    if ((self = [super init])) {
        stream = aStream;
        [stream open];
    }
    return self;
}

- (NSInteger)writeRootTag:(NSDictionary*)root withName:(NSString *)name error:(NSError **)error
{
    @try {
        return [self writeTag:root withName:name];
    }
    @catch (NSException *exception) {
        if (error) *error = [NBTKit _errorFromException:exception];
        return 0;
    }
}

- (NSInteger)writeTag:(id)obj withName:(NSString *)name
{
    NBTType tag = [NBTKit NBTTypeForObject:obj];
    NSInteger bytes = 0;
    // tag type
    bytes += [self writeByte:tag];
    // name
    bytes += [self writeString:name];
    // payload
    bytes += [self writeTag:obj ofType:tag];
    
    return bytes;
}

- (NSInteger)writeTag:(id)obj ofType:(NBTType)tag
{
    switch (tag) {
        case NBTTypeByte:
            return [self writeByte:[obj charValue]];
        case NBTTypeShort:
            return [self writeShort:[obj shortValue]];
        case NBTTypeInt:
            return [self writeInt:[obj intValue]];
        case NBTTypeLong:
            return [self writeLong:[obj longLongValue]];
        case NBTTypeFloat:
            return [self writeFloat:[obj floatValue]];
        case NBTTypeDouble:
            return [self writeDouble:[obj doubleValue]];
        case NBTTypeByteArray:
            return [self writeByteArray:obj];
        case NBTTypeString:
            return [self writeString:obj];
        case NBTTypeIntArray:
            return [self writeIntArray:obj];
        case NBTTypeLongArray:
            return [self writeLongArray:obj];
        case NBTTypeList:
            return [self writeList:obj];
        case NBTTypeCompound:
            return [self writeCompound:obj];
        case NBTTypeEnd:
        case NBTTypeInvalid:
        default:
            @throw [NSException exceptionWithName:@"NBTTypeException" reason:@"Unknown tag ID" userInfo:@{@"tag":@(tag)}];
    }
}

- (void)writeError
{
    NSMutableDictionary *userInfo = @{
        NSLocalizedFailureReasonErrorKey: @"Error writing NBT."
    }.mutableCopy;
    if ([stream propertyForKey:NSStreamFileCurrentOffsetKey]) {
        userInfo[NSStreamFileCurrentOffsetKey] = [stream propertyForKey:NSStreamFileCurrentOffsetKey];
    }
    if (stream.streamError) {
        userInfo[@"error"] = stream.streamError;
    }
    @throw [NSException exceptionWithName:@"NBTWriteException" reason:stream.streamError.description ?: @"Error writing NBT." userInfo:userInfo];
}

#pragma mark - Write basic types

- (NSInteger)write:(NSData*)data
{
    if (data == nil || data.length == 0) return 0;
    if ([stream write:data.bytes maxLength:data.length] != data.length) [self writeError];
    return data.length;
}

- (NSInteger)writeByte:(int8_t)val
{
    if ([stream write:(const uint8_t*)&val maxLength:1] != 1) [self writeError];
    return 1;
}

- (NSInteger)writeShort:(int16_t)val
{
    uint8_t buf[2];
    _littleEndian ? OSWriteLittleInt16(buf, 0, val) : OSWriteBigInt16(buf, 0, val);
    if ([stream write:buf maxLength:sizeof buf] != 2) [self writeError];
    return 2;
}

- (NSInteger)writeInt:(int32_t)val
{
    uint8_t buf[4];
    _littleEndian ? OSWriteLittleInt32(buf, 0, val) : OSWriteBigInt32(buf, 0, val);
    if ([stream write:buf maxLength:sizeof buf] != 4) [self writeError];
    return 4;
}

- (NSInteger)writeLong:(int64_t)val
{
    uint8_t buf[8];
    _littleEndian ? OSWriteLittleInt64(buf, 0, val) : OSWriteBigInt64(buf, 0, val);
    if ([stream write:buf maxLength:sizeof buf] != 8) [self writeError];
    return 8;
}

- (NSInteger)writeFloat:(float)val
{
    return [self writeInt:*(int32_t*)&val];
}

- (NSInteger)writeDouble:(double)val
{
    return [self writeLong:*(int64_t*)&val];
}

#pragma mark - Write compound types

- (NSInteger)writeByteArray:(NSData*)data
{
    NSInteger bw = 0;
    bw += [self writeInt:(int32_t)data.length];
    bw += [self write:data];
    return bw;
}

- (NSInteger)writeString:(NSString*)str
{
    NSInteger bw = 0;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    bw += [self writeShort:data.length];
    bw += [self write:data];
    return bw;
}

- (NSInteger)writeList:(NSArray*)list
{
    NBTType tag = NBTTypeByte;
    NSInteger bw = 0;
    if (list.count) tag = [NBTKit NBTTypeForObject:list.firstObject];
    bw += [self writeByte:tag];
    bw += [self writeInt:(int32_t)list.count];
    for (id obj in list) {
        bw += [self writeTag:obj ofType:tag];
    }
    return bw;
}

- (NSInteger)writeCompound:(NSDictionary*)dict
{
    NSInteger bw = 0;
    
    // items
    for (NSString *key in dict.nbtOrderedKeys) {
        bw += [self writeTag:dict[key] withName:key];
    }
    // TAG_End
    bw += [self writeByte:0];
    return bw;
}

- (NSInteger)writeIntArray:(NBTIntArray*)array
{
    NSInteger bw = 0;
    
    // length
    bw += [self writeInt:(int32_t)array.count];
    
    // values
    int32_t *values = array.values;
    for (NSUInteger i=0; i < array.count; i++) {
        bw += [self writeInt:values[i]];
    }
    
    return bw;
}

- (NSInteger)writeLongArray:(NBTLongArray*)array
{
    NSInteger bw = 0;
    
    // length
    bw += [self writeInt:(int32_t)array.count];
    
    // values
    int64_t *values = array.values;
    for (NSUInteger i=0; i < array.count; i++) {
        bw += [self writeLong:values[i]];
    }
    
    return bw;
}

@end
