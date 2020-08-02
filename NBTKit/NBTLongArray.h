//
//  NBTLongArray.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 31/07/2020.
//  Copyright © 2020 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class NBTLongArray
 *
 * Represents a variable-sized array of 64-bit integers.
 *
 * NBTLongArray objects allocate more memory as needed when elements are added.
 */
@interface NBTLongArray : NSObject <NSCopying>

/**
 * Creates and returns an NBTLongArray object containing the given values.
 *
 * @param values Array of int64_t values to initialize the NBTLongArray with.
 * @param count The number of items to copy from values.
 * @return A new NBTLongArray object with the given values.
 */
+ (instancetype)longArrayWithValues:(const int64_t*)values count:(NSUInteger)count;

/**
 * Creates and returns an NBTLongArray object containing a given number of zeroed values.
 *
 * @param newCount Number of values the array initially contains.
 * @return A new NBTLongArray object of newCount values, filled with zeros.
 */
+ (instancetype)longArrayWithCount:(NSUInteger)newCount;

/**
 * Creates and returns an empty NBTLongArray object capable of holding the specified number of values.
 *
 * The returned NBTLongArray will be empty, but allocate enough space to hold the specified number of
 * values initially. If more values are added, it will grow accordingly.
 *
 * @param newCapacity The number of values the new NBTLongArray object can initially contain.
 * @return A new empty NBTLongArray object.
 */
+ (instancetype)longArrayWithCapacity:(NSUInteger)newCapacity;

/**
 * Creates and returns an NBTLongArray object containing the values of the given NSArray
 *
 * The NBTLongArray is created with as many elements as the given NSArray, and their values
 * are set by calling intValue on each element of the NSArray.
 *
 * @param array Array of NSNumber objects to initialize the NBTLongArray with.
 * @return A new NBTLongArray object with the values of the given array.
 */
+ (instancetype)longArrayWithArray:(NSArray<NSNumber*>*)array;

/**
 * Returns an NBTLongArray object initialized with the given values.
 *
 * @param values Array of int64_t values to initialize the NBTLongArray with.
 * @param count The number of items to copy from ints.
 * @return NBTLongArray object with the given values.
 */
- (instancetype)initWithValues:(const int64_t*)values count:(NSUInteger)count;

/**
 * Returns an NBTLongArray object initialized with a given number of zeroed values.
 *
 * @param newCount Number of integers the array initially contains.
 * @return NBTLongArray object of newCount values, filled with zeros.
 */
- (instancetype)initWithCount:(NSUInteger)newCount;

/**
 * Returns an empty NBTLongArray object capable of holding the specified number of values.
 *
 * The returned NBTLongArray will be empty, but allocate enough space to hold the specified number of
 * values initially. If more values are added, it will grow accordingly.
 *
 * @param newCapacity The number of values the new NBTLongArray object can initially contain.
 * @return Empty NBTLongArray object.
 */
- (instancetype)initWithCapacity:(NSUInteger)newCapacity;

/**
 * Returns an NBTLongArray object containing the values of the given NSArray.
 *
 * The NBTLongArray is created with as many elements as the given NSArray, and their values
 * are set by calling intValue on each element of the NSArray.
 *
 * @param array Array of NSNumber objects to initialize the NBTLongArray with.
 * @return NBTLongArray object with the values of the given array.
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
 * If index is beyond the end of the NBTLongArray (that is, if index is greater than or equal to the value returned by count), an NSRangeException is raised.
 *
 * @param index The index of the value to retrieve.
 * @return value at the position given by index.
 */
- (int64_t)valueAtIndex:(NSUInteger)index;

/**
 * Returns the receiver's values.
 *
 * The returned value is a pointer to the object's internal storage, it may not be valid after subsequent
 * calls to this object.
 *
 * @return pointer to the receiver's internal values.
 */
- (int64_t*)values NS_RETURNS_INNER_POINTER;

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
- (void)addValue:(int64_t)value NS_SWIFT_NAME(add(value:));

/**
 * Adds values to the receiver.
 *
 * @param values Array of int64_t values to add to the receiver.
 * @param count The number of values to copy from values.
 */
- (void)addValues:(const int64_t*)values count:(NSUInteger)count NS_SWIFT_NAME(add(values:count:));

/**
 * Adds values of a NBTLongArray to the receiver.
 *
 * @param array NBTLongArray to add to the receiver.
 */
- (void)addLongArray:(NBTLongArray*)array;

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
- (void)replaceRange:(NSRange)range withValues:(int64_t*)values;

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
- (void)replaceRange:(NSRange)range withValues:(nullable int64_t*)values count:(NSUInteger)count;

/**
 * Replaces with a given NBTLongArray a given range within the contents of the receiver.
 *
 * If the location of range isn't within the receiver's range of values, an NSRangeException is raised.
 * If the length of range is not equal to count, the receiver is resized to accommodate the new values.
 * Any values past range in the receiver are shifted to accommodate the new values. You can therefore pass nil
 * for longArray to delete values in the receiver in the range range. You can also replace a range (which might
 * be zero-length) with more values than the length of the range, which has the effect of insertion.
 *
 * @param range The range within the contents of the receiver to be replaced by zeros. The range must not exceed the bounds of the receiver.
 * @param array NBTLongArray with values to insert in the receiver's contents.
 */
- (void)replaceRange:(NSRange)range withLongArray:(nullable NBTLongArray*)array;

@end

NS_ASSUME_NONNULL_END
