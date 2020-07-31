//
//  NBTLongArray.m
//  NBTKit
//
//  Created by Jesús A. Álvarez on 31/07/2020.
//  Copyright © 2020 namedfork. All rights reserved.
//

#import "NBTLongArray.h"

@implementation NBTLongArray
{
    int64_t *storage;
    NSUInteger length, capacity;
}

- (instancetype)initWithValues:(const int64_t*)values count:(NSUInteger)count
{
    if ((self = [super init])) {
        capacity = length = count;
        storage = capacity? calloc(capacity, sizeof(int64_t)) : NULL;
        if (storage) memcpy(storage, values, sizeof(int64_t)*count);
    }
    return self;
}

- (instancetype)initWithCount:(NSUInteger)newCount
{
    if ((self = [super init])) {
        capacity = length = newCount;
        storage = capacity? calloc(capacity, sizeof(int64_t)) : NULL;
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)newCapacity
{
    if ((self = [super init])) {
        length = 0;
        capacity = newCapacity;
        storage = capacity? calloc(capacity, sizeof(int64_t)) : NULL;
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array
{
    int64_t *values = calloc(array.count, sizeof(int64_t));
    NSUInteger i = 0;
    for (id obj in array) {
        values[i++] = [obj respondsToSelector:@selector(longValue)] ? [obj longValue] : 0;
    }
    self = [self initWithValues:values count:array.count];
    free(values);
    return self;
}

+ (instancetype)longArrayWithValues:(const int64_t *)values count:(NSUInteger)count
{
    return [[NBTLongArray alloc] initWithValues:values count:count];
}

+ (instancetype)longArrayWithCount:(NSUInteger)newCount
{
    return [[NBTLongArray alloc] initWithCount:newCount];
}

+ (instancetype)longArrayWithCapacity:(NSUInteger)newCapacity
{
    return [[NBTLongArray alloc] initWithCapacity:newCapacity];
}

+ (instancetype)longArrayWithArray:(NSArray *)array
{
    return [[NBTLongArray alloc] initWithArray:array];
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

- (void)setValue:(int64_t)value atIndex:(NSUInteger)idx
{
    if (idx >= length) @throw [NSException exceptionWithName:NSRangeException reason:@"Accessed NBTLongArray out of range" userInfo:nil];
    storage[idx] = value;
}

- (int64_t)valueAtIndex:(NSUInteger)idx
{
    if (idx >= length) @throw [NSException exceptionWithName:NSRangeException reason:@"Accessed NBTLongArray out of range" userInfo:nil];
    return storage[idx];
}

- (int64_t*)values NS_RETURNS_INNER_POINTER
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
        size_t new_size = (length + avail) * sizeof(int64_t);
        // round up to page size
        if (new_size % PAGE_SIZE) new_size += (PAGE_SIZE - (new_size % PAGE_SIZE));
        // embiggen the array
        storage = realloc(storage, new_size);
        capacity = new_size / sizeof(int64_t);
    }
}

- (void)addValue:(int64_t)value
{
    [self _ensureAvailableSpaces:1];
    storage[length++] = value;
}

- (void)addValues:(const int64_t*)values count:(NSUInteger)count
{
    [self _ensureAvailableSpaces:count];
    memcpy(&storage[length], values, count*sizeof(int64_t));
}

- (void)addLongArray:(NBTLongArray *)array
{
    [self addValues:array->storage count:array->length];
}

- (void)replaceRange:(NSRange)range withValues:(int64_t *)values
{
    [self replaceRange:range withValues:values count:range.length];
}

- (void)replaceRange:(NSRange)range withValues:(int64_t *)values count:(NSUInteger)count
{
    if (range.location+range.length > length) @throw [NSException exceptionWithName:NSRangeException reason:@"Accessed NBTLongArray out of range" userInfo:nil];
    if (count > range.length) [self _ensureAvailableSpaces:count-range.length];
    if (count != range.length && (length-(range.location+range.length)) > 0) {
        // move end to new position
        memmove(&storage[range.location+count], &storage[range.location+range.length], sizeof(int64_t)*(length-(range.location+range.length)));
    }
    
    // change length
    length += count - range.length;
    
    // copy new values
    if (count) {
        memcpy(&storage[range.location], values, sizeof(int64_t)*count);
    }
}

- (void)replaceRange:(NSRange)range withLongArray:(NBTLongArray *)array
{
    if (array == nil) {
        [self replaceRange:range withValues:NULL count:0];
    } else {
        [self replaceRange:range withValues:array->storage count:array->length];
    }
}

- (void)resetRange:(NSRange)range
{
    if (range.location+range.length > length) @throw [NSException exceptionWithName:NSRangeException reason:@"Accessed NBTLongArray out of range" userInfo:nil];
    while (range.length--) storage[range.location++] = 0;
}

- (BOOL)isEqual:(NBTLongArray*)array
{
    if (![array isKindOfClass:[NBTLongArray class]]) return NO;
    if (array->length != length) return NO;
    return memcmp(array->storage, storage, sizeof(int64_t)*length) == 0;
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
    return [[NBTLongArray allocWithZone:zone] initWithValues:storage count:length];
}

- (NSString *)description
{
    if (length == 0) return @"<NBTLongArray: ()>";
    NSMutableString *descr = @"<NBTLongArray: (".mutableCopy;
    for (NSUInteger i=0; i < length; i++) {
        [descr appendFormat:@"%lld,", storage[i]];
    }
    [descr replaceCharactersInRange:NSMakeRange(descr.length-1, 1) withString:@")>"];
    return descr;
}
@end
