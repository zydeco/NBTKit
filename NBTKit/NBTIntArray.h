//
//  NBTIntArray.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 30/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBTIntArray : NSObject <NSCopying>

+ (instancetype)intArrayWithValues:(const int32_t*)ints count:(NSUInteger)count;
+ (instancetype)intArrayWithCount:(NSUInteger)newCount;
+ (instancetype)intArrayWithCapacity:(NSUInteger)newCapacity;
+ (instancetype)intArrayWithArray:(NSArray*)array;
- (instancetype)initWithValues:(const int32_t*)ints count:(NSUInteger)count;
- (instancetype)initWithCount:(NSUInteger)newCount; // init with newCount values set to zero
- (instancetype)initWithCapacity:(NSUInteger)newCapacity; // init empty, but with given capacity
- (instancetype)initWithArray:(NSArray*)array; // array of NSNumber

@property (nonatomic) NSUInteger count;

// reading
- (int32_t)valueAtIndex:(NSUInteger)idx;
- (int32_t*)values NS_RETURNS_INNER_POINTER; // internal pointer, may not be valid after modifying this NBTIntArray
- (NSArray*)array; // array of NSNumber

// writing
- (void)addValue:(int32_t)value;
- (void)addValues:(const int32_t*)values count:(NSUInteger)count;
- (void)addIntArray:(NBTIntArray*)intArray;
- (void)resetRange:(NSRange)range; // set values in range to zero
- (void)replaceRange:(NSRange)range withValues:(int32_t*)values;
- (void)replaceRange:(NSRange)range withValues:(int32_t*)values count:(NSUInteger)count; // array will be expanded or contracted depending on count
- (void)replaceRange:(NSRange)range withIntArray:(NBTIntArray*)intArray; // array will be expanded or contracted depending on the size of intArray

@end
