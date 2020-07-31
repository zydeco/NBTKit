//
//  main.m
//  nbtdump
//
//  Created by Jesús A. Álvarez on 31/07/2020.
//  Copyright © 2020 namedfork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBTKit.h"

void usage(void) {
    fprintf(stderr, "usage: nbtdump [--compressed] [--little_endian] file\n");
    exit(EXIT_FAILURE);
}

// Parses arguments and flags, returns false if there's an unknown flag
BOOL ParseArguments(NSSet<NSString*> ** flags, NSArray<NSString*>** args, BOOL includeProgramName, NSSet<NSString*> * knownFlags) {
    BOOL canHasFlags = YES;
    NSMutableSet<NSString*> *parsedFlags = [NSMutableSet setWithCapacity:8];
    NSMutableArray<NSString*> *parsedArgs = [NSMutableArray arrayWithCapacity:8];
    for (NSString *arg in NSProcessInfo.processInfo.arguments) {
        if (canHasFlags && [arg isEqualToString:@"--"]) {
            canHasFlags = NO;
            continue;
        }
        if (canHasFlags && [arg hasPrefix:@"-"]) {
            [parsedFlags addObject:arg];
        } else {
            [parsedArgs addObject:arg];
        }
    }
    if (!includeProgramName) {
        [parsedArgs removeObjectAtIndex:0];
    }
    if (flags) {
        *flags = [NSSet setWithSet:parsedFlags];
    }
    if (args) {
        *args = [NSArray arrayWithArray:parsedArgs];
    }
    [parsedFlags minusSet:knownFlags];
    return parsedFlags.count == 0;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSSet<NSString*> *flags = nil;
        NSArray<NSString*> *args = nil;
        NSSet<NSString*> *knownFlags = [NSSet setWithObjects:@"--little_endian", @"--compressed", nil];
        if (!ParseArguments(&flags, &args, NO, knownFlags)) {
            NSArray<NSString*> *unknownFlags = [flags objectsPassingTest:^BOOL(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                return ![knownFlags containsObject:obj];
            }].allObjects;
            fprintf(stderr, "Unknown flags: %s\n", [unknownFlags componentsJoinedByString:@", "].UTF8String);
            usage();
        }
        NSString *path = args.lastObject;
        if (args.count != 1) {
            usage();
        }
                
        NBTOptions options = 0;
        if ([flags containsObject:@"--little_endian"]) {
            options |= NBTLittleEndian;
        }
        if ([flags containsObject:@"--compressed"]) {
            options |= NBTCompressed;
        }
        
        NSError *error = nil;
        NSString *rootTag = nil;
        NSMutableDictionary *nbt = [NBTKit NBTWithFile:path name:&rootTag options:options error:&error];
        if (error) {
            fprintf(stderr, "Error reading NBT: %s\n", error.description.UTF8String);
            exit(EXIT_FAILURE);
        }
        
        if (rootTag.length > 0) {
            printf("%s:\n", rootTag.UTF8String);
        }
        printf("%s\n", nbt.description.UTF8String);
    }
    return 0;
}
