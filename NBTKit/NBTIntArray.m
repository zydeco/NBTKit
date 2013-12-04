//
//  NBTIntArray.m
//  NBTKit
//
//  Created by Jesús A. Álvarez on 30/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import "NBTIntArray.h"

@implementation NBTIntArray
{
    int32_t *storage;
    NSUInteger length, capacity;
}

- (instancetype)initWithValues:(const int32_t*)values count:(NSUInteger)count
{
    if ((self = [super init])) {
        capacity = length = count;
        storage = capacity? calloc(capacity, sizeof(int32_t)) : NULL;
        if (storage) memcpy(storage, values, sizeof(int32_t)*count);
    }
    return self;
}

- (instancetype)initWithCount:(NSUInteger)newCount
{
    if ((self = [super init])) {
        capacity = length = newCount;
        storage = capacity? calloc(capacity, sizeof(int32_t)) : NULL;
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)newCapacity
{
    if ((self = [super init])) {
        length = 0;
        capacity = newCapacity;
        storage = capacity? calloc(capacity, sizeof(int32_t)) : NULL;
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array
{
    int32_t *values = calloc(array.count, sizeof(int32_t));
    NSUInteger i = 0;
    for (id obj in array) {
        values[i++] = [obj respondsToSelector:@selector(intValue)] ? [obj intValue] : 0;
    }
    self = [self initWithValues:values count:array.count];
    free(values);
    return self;
}

+ (instancetype)intArrayWithValues:(const int32_t *)values count:(NSUInteger)count
{
    return [[NBTIntArray alloc] initWithValues:values count:count];
}

+ (instancetype)intArrayWithCount:(NSUInteger)newCount
{
    return [[NBTIntArray alloc] initWithCount:newCount];
}

+ (instancetype)intArrayWithCapacity:(NSUInteger)newCapacity
{
    return [[NBTIntArray alloc] initWithCapacity:newCapacity];
}

+ (instancetype)intArrayWithArray:(NSArray *)array
{
    return [[NBTIntArray alloc] initWithArray:array];
}

- (void)dealloc
{
    free(storage);
}

- (NSUInteger)count
{
    return length;
}

- (void)setCount:(NSUInteger)newCount
{
    if (newCount > length) {
        // embiggen
        [self _ensureAvailableSpaces:newCount];
        while (newCount--) storage[length++] = 0;
    } else {
        // truncate (or not)
        length = newCount;
    }
}

- (void)setValue:(int32_t)value atIndex:(NSUInteger)idx
{
    if (idx >= length) @throw [NSException exceptionWithName:NSRangeException reason:@"Accessed NBTIntArray out of range" userInfo:nil];
    storage[idx] = value;
}

- (int32_t)valueAtIndex:(NSUInteger)idx
{
    if (idx >= length) @throw [NSException exceptionWithName:NSRangeException reason:@"Accessed NBTIntArray out of range" userInfo:nil];
    return storage[idx];
}

- (int32_t*)values NS_RETURNS_INNER_POINTER
{
    return storage;
}

- (NSArray *)array
{
    id objects[length];
    for (NSUInteger i=0; i < length; i++) {
        objects[i] = @(storage[i]);
    }
    return [NSArray arrayWithObjects:objects count:length];
}

- (void)_ensureAvailableSpaces:(NSUInteger)avail
{
    if (capacity - length < avail) {
        size_t new_size = (length + avail) * sizeof(int32_t);
        // round up to page size
        if (new_size % PAGE_SIZE) new_size += (PAGE_SIZE - (new_size % PAGE_SIZE));
        // embiggen the array
        storage = realloc(storage, new_size);
        capacity = new_size / sizeof(int32_t);
    }
}

- (void)addValue:(int32_t)value
{
    [self _ensureAvailableSpaces:1];
    storage[length++] = value;
}

- (void)addValues:(const int32_t*)values count:(NSUInteger)count
{
    [self _ensureAvailableSpaces:count];
    memcpy(&storage[length], values, count*sizeof(int32_t));
}

- (void)addIntArray:(NBTIntArray*)intArray
{
    [self addValues:intArray->storage count:intArray->length];
}

- (void)replaceRange:(NSRange)range withValues:(int32_t *)values
{
    [self replaceRange:range withValues:values count:range.length];
}

- (void)replaceRange:(NSRange)range withValues:(int32_t *)values count:(NSUInteger)count
{
    if (range.location+range.length > length) @throw [NSException exceptionWithName:NSRangeException reason:@"Accessed NBTIntArray out of range" userInfo:nil];
    if (count > range.length) [self _ensureAvailableSpaces:count-range.length];
    if (count != range.length && (length-(range.location+range.length)) > 0) {
        // move end to new position
        memmove(&storage[range.location+count], &storage[range.location+range.length], sizeof(int32_t)*(length-(range.location+range.length)));
    }
    
    // change length
    length += count - range.length;
    
    // copy new values
    memcpy(&storage[range.location], values, sizeof(int32_t)*count);
}

- (void)replaceRange:(NSRange)range withIntArray:(NBTIntArray *)intArray
{
    [self replaceRange:range withValues:intArray->storage count:intArray->length];
}

- (void)resetRange:(NSRange)range
{
    if (range.location+range.length > length) @throw [NSException exceptionWithName:NSRangeException reason:@"Accessed NBTIntArray out of range" userInfo:nil];
    while (range.length--) storage[range.location++] = 0;
}

- (BOOL)isEqual:(NBTIntArray*)intArray
{
    if (![intArray isKindOfClass:[NBTIntArray class]]) return NO;
    if (intArray->length != length) return NO;
    return memcmp(intArray->storage, storage, sizeof(int32_t)*length) == 0;
}

- (NSUInteger)hash
{
    NSUInteger hash = length;
    for (int i=12; i < sizeof(NSUInteger)/8; i+=4) {
        if (length <= (i-12)/4) break;
        hash ^= storage[(i-12)/4] << i;
    }
    return hash;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NBTIntArray allocWithZone:zone] initWithValues:storage count:length];
}

- (NSString *)description
{
    if (length == 0) return @"<NBTIntArray: ()>";
    NSMutableString *descr = @"<NBTIntArray: (".mutableCopy;
    for (NSUInteger i=0; i < length; i++) {
        [descr appendFormat:@"%d,", storage[i]];
    }
    [descr replaceCharactersInRange:NSMakeRange(descr.length-1, 1) withString:@")>"];
    return descr;
}
@end
