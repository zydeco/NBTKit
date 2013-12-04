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

typedef NS_ENUM(int8_t, NBTType) {
    NBT_Invalid = -1,
    NBT_End,
    NBT_Byte,
    NBT_Short,
    NBT_Int,
    NBT_Long,
    NBT_Float,
    NBT_Double,
    NBT_Byte_Array,
    NBT_String,
    NBT_List,
    NBT_Compound,
    NBT_Int_Array
};

@interface NBTKit (Private)
+ (NBTType)NBTTypeForObject:(id)obj;
+ (BOOL)_isValidList:(NSArray*)array;
+ (BOOL)_isValidCompound:(NSDictionary*)dict;
@end

#endif
