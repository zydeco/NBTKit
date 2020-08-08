//
//  NBTKit_Private.h
//  NBTKit
//
//  Created by Jesús A. Álvarez on 29/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#ifndef NBTKit_NBTKit_Private_h
#define NBTKit_NBTKit_Private_h

#import "NBTKit.h"
#import <Foundation/Foundation.h>
#import <mach/vm_page_size.h>

@interface NBTKit (Private)
+ (BOOL)_isValidList:(nullable NSArray*)array;
+ (BOOL)_isValidCompound:(nullable NSDictionary*)dict;
+ (nonnull NSError*)_errorFromException:(nullable NSException*)exception;
@end

@interface NSArray (NBTListTypePrivate)
- (void)setNbtListType:(NBTType)listType;
@end
#endif
