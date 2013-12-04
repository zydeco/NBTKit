//
//  NBTWriter.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 30/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBTWriter : NSObject

@property (nonatomic, assign) BOOL littleEndian;

- (instancetype)initWithStream:(NSOutputStream *)stream;
- (NSInteger)writeRootTag:(NSDictionary*)root withName:(NSString *)name error:(NSError **)error;

@end
