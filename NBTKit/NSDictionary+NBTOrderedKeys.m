//
//  NSDictionary+NBTOrderedKeys.m
//  NBTKit
//
//  Created by Jesús A. Álvarez on 09/08/2020.
//  Copyright © 2020 namedfork. All rights reserved.
//

#import "NBTKit.h"
#import "NBTKit_Private.h"
#import <objc/runtime.h>

static void * NBTOrderedKeysKey = &NBTOrderedKeysKey;

@implementation NSDictionary (NBTOrderedKeys)

- (NSOrderedSet<NSString*>*)nbtOrderedKeys {
    NSMutableOrderedSet<NSString*> *orderedKeys = objc_getAssociatedObject(self, NBTOrderedKeysKey);
    if (orderedKeys == nil) {
        orderedKeys = [NSMutableOrderedSet orderedSetWithCapacity:self.count];
        objc_setAssociatedObject(self, NBTOrderedKeysKey, orderedKeys, OBJC_ASSOCIATION_RETAIN);
    }
    NSSet *allKeysSet = [NSSet setWithArray:self.allKeys];
    [orderedKeys intersectSet:allKeysSet];
    [orderedKeys unionSet:allKeysSet];
    return orderedKeys;
}

- (void)setNbtOrderedKeys:(NSOrderedSet<NSString*>*)nbtOrderedKeys {
    objc_setAssociatedObject(self, NBTOrderedKeysKey, nbtOrderedKeys.mutableCopy, OBJC_ASSOCIATION_RETAIN);
}

@end
