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
    if (assObj == nil && self.count > 0 && [NBTKit _isValidList:self]) {
        // set to type of first object
        NBTType listType = [NBTKit NBTTypeForObject:self.firstObject];
        assObj = @(listType);
        objc_setAssociatedObject(self, NBTListTypeKey, assObj, OBJC_ASSOCIATION_COPY);
    }
    return assObj ? (NBTType)assObj.intValue : NBTTypeEnd;
}

@end

@implementation NSArray (NBTListTypePrivate)

- (void)setNbtListType:(NBTType)listType {
    objc_setAssociatedObject(self, NBTListTypeKey, @(listType), OBJC_ASSOCIATION_COPY);
}

@end
