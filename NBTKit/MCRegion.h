//
//  MCRegion.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 30/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCRegion : NSObject

+ (instancetype)mcrWithFileAtPath:(NSString*)path;
- (instancetype)initWithFileAtPath:(NSString*)path;
- (BOOL)rewrite; // rewrite whole file

// chunk get/set
// x and z are relative to this region (0-31)
// nil means no chunk
- (NSMutableDictionary*)getChunkAtX:(NSInteger)x Z:(NSInteger)z;
- (BOOL)setChunk:(NSDictionary*)root atX:(NSInteger)x Z:(NSInteger)z;

@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

@end
