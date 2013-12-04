//
//  NBTReader.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 29/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBTReader : NSObject

@property (nonatomic, assign) BOOL littleEndian;

- (instancetype)initWithStream:(NSInputStream *)stream;
- (id)readRootTag:(NSString **)name error:(NSError **)error;

@end
