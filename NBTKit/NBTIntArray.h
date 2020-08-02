//
//  NBTIntArray.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 30/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class NBTIntArray
 *
 * Represents a variable-sized array of 32-bit integers.
 *
 * NBTIntArray objects allocate more memory as needed when elements are added.
 */
@interface NBTIntArray : NSObject <NSCopying>

/**
 * Creates and returns an NBTIntArray object containing the given values.
 *
 * @param ints Array of int32_t values to initialize the NBTIntArray with.
 * @param count The number of items to copy from ints.
 * @return A new NBTIntArray object with the given values.
 */
+ (instancetype)intArrayWithValues:(const int32_t*)ints count:(NSUInteger)count;

/**
 * Creates and returns an NBTIntArray object containing a given number of zeroed values.
 *
 * @param newCount Number of integers the array initially contains.
 * @return A new NBTIntArray object of newCount values, filled with zeros.
 */
+ (instancetype)intArrayWithCount:(NSUInteger)newCount;

/**
 * Creates and returns an empty NBTIntArray object capable of holding the specified number of values.
 *
 * The returned NBTIntArray will be empty, but allocate enough space to hold the specified number of 
 * values initially. If more values are added, it will grow accordingly.
 *
 * @param newCapacity The number of values the new NBTIntArray object can initially contain.
 * @return A new empty NBTIntArray object.
 */
+ (instancetype)intArrayWithCapacity:(NSUInteger)newCapacity;

/**
 * Creates and returns an NBTIntArray object containing the values of the given NSArray
 *
 * The NBTIntArray is created with as many elements as the given NSArray, and their values
 * are set by calling intValue on each element of the NSArray.
 *
 * @param array Array of NSNumber objects to initialize the NBTIntArray with.
 * @return A new NBTIntArray object with the values of the given array.
 */
+ (instancetype)intArrayWithArray:(NSArray<NSNumber*>*)array;

/**
 * Returns an NBTIntArray object initialized with the given values.
 *
 * @param ints Array of int32_t values to initialize the NBTIntArray with.
 * @param count The number of items to copy from ints.
 * @return NBTIntArray object with the given values.
 */
- (instancetype)initWithValues:(const int32_t*)ints count:(NSUInteger)count;

/**
 * Returns an NBTIntArray object initialized with a given number of zeroed values.
 *
 * @param newCount Number of integers the array initially contains.
 * @return NBTIntArray object of newCount values, filled with zeros.
 */
- (instancetype)initWithCount:(NSUInteger)newCount;

/**
 * Returns an empty NBTIntArray object capable of holding the specified number of values.
 *
 * The returned NBTIntArray will be empty, but allocate enough space to hold the specified number of
 * values initially. If more values are added, it will grow accordingly.
 *
 * @param newCapacity The number of values the new NBTIntArray object can initially contain.
 * @return Empty NBTIntArray object.
 */
- (instancetype)initWithCapacity:(NSUInteger)newCapacity;

/**
 * Returns an NBTIntArray object containing the values of the given NSArray.
 *
 * The NBTIntArray is created with as many elements as the given NSArray, and their values
 * are set by calling intValue on each element of the NSArray.
 *
 * @param array Array of NSNumber objects to initialize the NBTIntArray with.
 * @return NBTIntArray object with the values of the given array.
 */
- (instancetype)initWithArray:(NSArray<NSNumber*>*)array;

/**
 * The number of elements contained in the receiver.
 * If extended, the additional values are filled with zeros.
 */
@property (nonatomic) NSUInteger count;

/**
 * Returns the value at the given position.
 *
 * If index is beyond the end of the NBTIntArray (that is, if index is greater than or equal to the value returned by count), an NSRangeException is raised.
 *
 * @param index The index of the value to retrieve.
 * @return value at the position given by index.
 */
- (int32_t)valueAtIndex:(NSUInteger)index;

/**
 * Returns the receiver's values.
 *
 * The returned value is a pointer to the object's internal storage, it may not be valid after subsequent
 * calls to this object.
 *
 * @return pointer to the receiver's internal values.
 */
- (int32_t*)values NS_RETURNS_INNER_POINTER;

/**
 * Returns the receiver's values as a NSArray with NSNumber components.
 *
 * @return New NSArray containing NSNumber objects with the values of the receiver.
 */
- (NSArray<NSNumber*>*)array;

/**
 * Adds a value to the receiver.
 *
 * @param value Value to add.
 */
- (void)addValue:(int32_t)value NS_SWIFT_NAME(add(value:));

/** 
 * Adds values to the receiver.
 *
 * @param values Array of int32_t values to add to the receiver.
 * @param count The number of values to copy from values.
 */
- (void)addValues:(const int32_t*)values count:(NSUInteger)count NS_SWIFT_NAME(add(values:count:));

/**
 * Adds values of a NBTIntArray to the receiver.
 *
 * @param intArray NBTIntArray to add to the receiver.
 */
- (void)addIntArray:(NBTIntArray*)intArray;

/**
 * Replaces with zeroes the contents of the receiver in a given range.
 *
 * If the location of range isn't within the receiver's range of values, an NSRangeException is raised.
 *
 * @param range The range within the contents of the receiver to be replaced by zeros. The range must not exceed the bounds of the receiver.
 */
- (void)resetRange:(NSRange)range NS_SWIFT_NAME(reset(range:));

/**
 * Replaces with a given set of values a given range within the contents of the receiver.
 *
 * If the location of range isn't within the receiver's range of values, an NSRangeException is raised.
 *
 * @param range The range within the contents of the receiver to be replaced by zeros. The range must not exceed the bounds of the receiver.
 * @param values The values to insert in the receiver's contents.
 */
- (void)replaceRange:(NSRange)range withValues:(int32_t*)values;

/**
 * Replaces with a given set of values a given range within the contents of the receiver.
 *
 * If the location of range isn't within the receiver's range of values, an NSRangeException is raised.
 * If the length of range is not equal to count, the receiver is resized to accommodate the new values.
 * Any values past range in the receiver are shifted to accommodate the new values. You can therefore pass NULL 
 * for values and 0 for count to delete values in the receiver in the range range. You can also replace a range 
 * (which might be zero-length) with more values than the length of the range, which has the effect of insertion.
 *
 * @param range The range within the contents of the receiver to be replaced by zeros. The range must not exceed the bounds of the receiver.
 * @param values The values to insert in the receiver's contents.
 * @param count The number of values to take from values.
 */
- (void)replaceRange:(NSRange)range withValues:(nullable int32_t*)values count:(NSUInteger)count;

/**
 * Replaces with a given NBTIntArray a given range within the contents of the receiver.
 *
 * If the location of range isn't within the receiver's range of values, an NSRangeException is raised.
 * If the length of range is not equal to count, the receiver is resized to accommodate the new values.
 * Any values past range in the receiver are shifted to accommodate the new values. You can therefore pass nil
 * for intArray to delete values in the receiver in the range range. You can also replace a range (which might 
 * be zero-length) with more values than the length of the range, which has the effect of insertion.
 *
 * @param range The range within the contents of the receiver to be replaced by zeros. The range must not exceed the bounds of the receiver.
 * @param intArray NBTIntArray with values to insert in the receiver's contents.
 */
- (void)replaceRange:(NSRange)range withIntArray:(nullable NBTIntArray*)intArray;

@end

NS_ASSUME_NONNULL_END
