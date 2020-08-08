//
//  NSArray+NBTListType.m
//  NBTKit
//
//  Created by Jesús A. Álvarez on 08/08/2020.
//  Copyright © 2020 namedfork. All rights reserved.
//

#import "NBTKit.h"
#import "NBTKit_Private.h"
#import <objc/runtime.h>

static void * NBTListTypeKey = &NBTListTypeKey;

@implementation NSArray (NBTListType)

- (NBTType)nbtListType {
    NSNumber *assObj = objc_getAssociatedObject(self, NBTListTypeKey);
    return assObj ? (NBTType)assObj.intValue : NBTTypeInvalid;
}

@end

@implementation NSArray (NBTListTypePrivate)

- (void)setNbtListType:(NBTType)listType {
    objc_setAssociatedObject(self, NBTListTypeKey, @(listType), OBJC_ASSOCIATION_COPY);
}

@end
