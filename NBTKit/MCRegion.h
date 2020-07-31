//
//  MCRegion.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 30/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @class MCRegion
 * Represents a region file (.mcr or .mca), and allows read/write access to its chunks.
 */
@interface MCRegion : NSObject

/**
 * Creates and returns an initialized MCRegion object representing a file at a given path.
 * @param path Path to the file (if it doesn't exist, a new region file will be created).
 * @return An initialized MCRegion object representing the file at path, or nil if the file exists but isn't a valid region file.
 */
+ (nullable instancetype)mcrWithFileAtPath:(NSString*)path;

/**
 * Initializes and returns a MCRegion object representing a file at a given path.
 * @param path Path to the file (if it doesn't exist, a new region file will be created).
 * @return An initialized MCRegion object representing the file at path, or nil if the file exists but isn't a valid region file.
 */
- (nullable instancetype)initWithFileAtPath:(NSString*)path;

/**
 * Rewrites all the chunks in the file, getting rid of fragmentation.
 *
 * This method raises an exception if no free space is left on the file system, or if any other writing error occurs.
 *
 * @return Number of bytes saved by rewriting
 */
- (NSInteger)rewrite;

/**
 * Gets a chunk from the region file, in coordinates relative to the region file (0-31)
 *
 * @param x X coordinate of the chunk (0-31)
 * @param z Z coordinate of the chunk (0-31)
 * @return the chunk's root tag, or nil if the chunk is empty or the coordinates are invalid
 */
- (nullable NSMutableDictionary*)getChunkAtX:(NSInteger)x Z:(NSInteger)z;

/**
 * Writes a chunk to the region file, or removes it.
 *
 * If a chunk is too big (more than 1MB when compressed), it won't fit the region format, and return NO.
 * This method raises an exception if no free space is left on the file system, or if any other writing error occurs.
 *
 * @param root root tag of the chunk. Pass nil to remove the chunk from the file.
 * @param x X coordinate of the chunk (0-31)
 * @param z Z coordinate of the chunk (0-31)
 * @return YES on success, NO if the chunk is too big or the coordinates are invalid
 */
- (BOOL)setChunk:(nullable NSDictionary*)root atX:(NSInteger)x Z:(NSInteger)z;

/// YES if the region contains no chunks
@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

@end

NS_ASSUME_NONNULL_END
