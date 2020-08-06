//
//  NBTKit.m
//  NBTKit
//
//  Created by Jesús A. Álvarez on 29/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import "NBTKit.h"
#import "NBTKit_Private.h"
#import "NBTReader.h"
#import "NBTWriter.h"
#import <zlib.h>

NSErrorDomain const NBTKitErrorDomain = @"NBTKitErrorDomain";

@implementation NBTKit

+ (NSMutableDictionary *)NBTWithData:(NSData *)data name:(NSString *__autoreleasing *)name options:(NBTOptions)opt error:(NSError *__autoreleasing *)error
{
    if (data == nil) return nil;
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    [stream open];
    return [self NBTWithStream:stream name:name options:opt error:error];
}

+ (NSMutableDictionary *)NBTWithFile:(NSString *)path name:(NSString *__autoreleasing *)name options:(NBTOptions)opt error:(NSError *__autoreleasing *)error
{
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:path];
    [stream open];
    return [self NBTWithStream:stream name:name options:opt error:error];
}

+ (NSMutableDictionary *)NBTWithStream:(NSInputStream *)stream name:(NSString *__autoreleasing *)name options:(NBTOptions)opt error:(NSError *__autoreleasing *)error
{
    if (opt & NBTCompressed) {
        // read whole stream (yes, it's inefficient)
        uint8_t buf[1024];
        NSMutableData *zdata = [NSMutableData new];
        while (stream.hasBytesAvailable) {
            NSInteger br = [stream read:buf maxLength:sizeof buf];
            if (br > 0) [zdata appendBytes:buf length:br];
            if (br < 0) {
                // error
                if (error) *error = stream.streamError;
                return nil;
            }
        }
        
        // decompress
        NSMutableData *nbtData = [NSMutableData new];
        z_stream zstream = {
            .zalloc   = Z_NULL,
            .zfree    = Z_NULL,
            .opaque   = Z_NULL,
            .next_in  = (void*)zdata.bytes,
            .avail_in = (uInt)zdata.length
        };
        
        int zerr = inflateInit2(&zstream, 15 + 32);
        if(zerr != Z_OK) goto zlibError;
        
        do {
            // set output buffer
            zstream.next_out = buf;
            zstream.avail_out = sizeof buf;
            
            // inflate
            zerr = inflate(&zstream, Z_NO_FLUSH);
            if (zerr == Z_MEM_ERROR || zerr == Z_DATA_ERROR || zerr == Z_NEED_DICT) goto zlibError;
            
            // add to decompressed data
            [nbtData appendBytes:buf length:sizeof buf - zstream.avail_out];
        } while (zstream.avail_out == 0);
        
        if(zerr != Z_STREAM_END) goto zlibError;
        inflateEnd(&zstream);
        
        // read uncompressed NBT
        return [self NBTWithData:nbtData name:name options:opt &~ NBTCompressed error:error];
    zlibError:
        inflateEnd(&zstream);
        if (error) *error = [NSError errorWithDomain:@"ZLib" code:zerr userInfo:@{@"message": [[NSString alloc] initWithUTF8String:zError(zerr)]}];
        return nil;
    } else {
        // read uncompressed NBT
        NBTReader *reader = [[NBTReader alloc] initWithStream:stream];
        reader.littleEndian = opt & NBTLittleEndian;
        return [reader readRootTag:name error:error];
    }
}

+ (NSData *)dataWithNBT:(NSDictionary*)root name:(NSString*)name options:(NBTOptions)opt error:(NSError **)error
{
    NSError *inError = nil;
    NSOutputStream *stream = [NSOutputStream outputStreamToMemory];
    [stream open];
    [self writeNBT:root name:name toStream:stream options:opt error:&inError];
    if (error) *error = inError;
    if (inError) return nil;
    return [stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
}

+ (NSInteger)writeNBT:(NSDictionary *)base name:(NSString *)name toFile:(NSString *)path options:(NBTOptions)opt error:(NSError *__autoreleasing *)error
{
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [stream open];
    return [self writeNBT:base name:name toStream:stream options:opt error:error];
}

+ (NSInteger)writeNBT:(NSDictionary *)root name:(NSString*)name toStream:(NSOutputStream *)stream options:(NBTOptions)opt error:(NSError *__autoreleasing *)error
{
    if (stream == nil) {
        if (error) *error = [NSError errorWithDomain:NBTKitErrorDomain code:NBTInvalidArgError userInfo:@{@"stream": stream}];
        return 0;
    }
    
    if (opt & NBTCompressed) {
        // get uncompressed data
        NSData *nbtData = [self dataWithNBT:root name:name options:opt &~ NBTCompressed error:error];
        if (nbtData == nil) return 0;
        
        // compress
        z_stream zstream = {
            .zalloc   = Z_NULL,
            .zfree    = Z_NULL,
            .opaque   = Z_NULL,
            .next_in  = (void*)nbtData.bytes,
            .avail_in = (uInt)nbtData.length
        };
        
        uint8_t buf[1024];
        int zerr = deflateInit2(&zstream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, opt & NBTUseZlib ? 15 : 31, 8, Z_DEFAULT_STRATEGY);
        if (zerr != Z_OK) goto zlibError;
        
        NSInteger bw = 0;
        do {
            zstream.next_out = buf;
            zstream.avail_out = sizeof buf;
            
            zerr = deflate(&zstream, Z_FINISH);
            if (zerr == Z_STREAM_ERROR) goto zlibError;
            
            bw += [stream write:buf maxLength:sizeof buf - zstream.avail_out];
        } while (zstream.avail_out == 0);
        
        deflateEnd(&zstream);
        return bw;
    zlibError:
        deflateEnd(&zstream);
        if (error) *error = [NSError errorWithDomain:@"ZLib" code:zerr userInfo:@{@"message": [[NSString alloc] initWithUTF8String:zError(zerr)]}];
        return 0;
    } else {
        // check types
        if (![self isValidNBTObject:root]) {
            if (error) *error = [NSError errorWithDomain:NBTKitErrorDomain code:NBTTypeError userInfo:@{NSLocalizedFailureReasonErrorKey: @"Invalid NBT object"}];
            return 0;
        }
        
        // write NBT
        NBTWriter *writer = [[NBTWriter alloc] initWithStream:stream];
        writer.littleEndian = opt & NBTLittleEndian;
        return [writer writeRootTag:root withName:name error:error];
    }
}

+ (NBTType)NBTTypeForObject:(id)obj
{
    if ([obj isKindOfClass:[NBTByte class]])        return NBT_Byte;
    if ([obj isKindOfClass:[NBTShort class]])       return NBT_Short;
    if ([obj isKindOfClass:[NBTInt class]])         return NBT_Int;
    if ([obj isKindOfClass:[NBTLong class]])        return NBT_Long;
    if ([obj isKindOfClass:[NBTFloat class]])       return NBT_Float;
    if ([obj isKindOfClass:[NBTDouble class]])      return NBT_Double;
    if ([obj isKindOfClass:[NSData class]])         return NBT_Byte_Array;
    if ([obj isKindOfClass:[NSString class]])       return NBT_String;
    if ([obj isKindOfClass:[NSArray class]])        return NBT_List;
    if ([obj isKindOfClass:[NSDictionary class]])   return NBT_Compound;
    if ([obj isKindOfClass:[NBTIntArray class]])    return NBT_Int_Array;
    if ([obj isKindOfClass:[NBTLongArray class]])   return NBT_Long_Array;
    return NBT_Invalid;
}

+ (BOOL)_isValidList:(NSArray*)array
{
    // NBT lists have all items of same kind
    if (array.count == 0) return YES;
    NBTType type = [self NBTTypeForObject:array.firstObject];
    for (id obj in array) {
        if ([self NBTTypeForObject:obj] != type) return NO;
        if (![self isValidNBTObject:obj]) return NO;
    }
    return YES;
}

+ (BOOL)_isValidCompound:(NSDictionary*)dict
{
    // NBT compounds have keys as strings, and NBT objects as values
    if (dict.count == 0) return YES;
    for (id key in dict.allKeys) {
        if (![key isKindOfClass:[NSString class]]) return NO;
    }
    for (id obj in dict.allValues) {
        if (![self isValidNBTObject:obj]) return NO;
    }
    return YES;
}

+ (BOOL)isValidNBTObject:(id)obj
{
    switch ([self NBTTypeForObject:obj]) {
        case NBT_Byte:
        case NBT_Short:
        case NBT_Int:
        case NBT_Long:
        case NBT_Float:
        case NBT_Double:
        case NBT_Byte_Array:
        case NBT_String:
        case NBT_Int_Array:
        case NBT_Long_Array:
            return YES;
        case NBT_List:
            return [self _isValidList:obj];
        case NBT_Compound:
            return [self _isValidCompound:obj];
        case NBT_End:
        case NBT_Invalid:
        default:
            return NO;
    }
}

+ (NSError*)_errorFromException:(NSException*)exception
{
    if (exception.userInfo[@"error"]) {
        return exception.userInfo[@"error"];
    } else if ([exception.name isEqualToString:@"NBTTypeException"]) {
        NSMutableDictionary *userInfo = exception.userInfo.mutableCopy;
        userInfo[NSLocalizedFailureReasonErrorKey] = exception.reason;
        return [NSError errorWithDomain:NBTKitErrorDomain code:NBTTypeError userInfo:userInfo];
    } else if ([exception.name isEqualToString:@"NBTReadException"]) {
        return [NSError errorWithDomain:NBTKitErrorDomain code:NBTReadError userInfo:exception.userInfo];
    } else if ([exception.name isEqualToString:@"NBTWriteException"]) {
        return [NSError errorWithDomain:NBTKitErrorDomain code:NBTWriteError userInfo:exception.userInfo];
    } else {
        return [NSError errorWithDomain:NBTKitErrorDomain code:NBTErrorGeneral userInfo:@{NSLocalizedFailureReasonErrorKey: exception.reason}];
    }
}

@end
