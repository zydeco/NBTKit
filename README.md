# NBTKit
Objective-C library for reading and writing Minecraft NBT and region files.

## Features

* Read and write NBT
* Representation with Foundation objects and additional NBTKit types
* Support compressed data (GZip and Zlib)
* Read and write region files (mcr and mca) 
* Support big endian and little endian NBT

## Types
NBT types are converted to and from native types according to the following table:

| Tag Type         | Native Type           | Description                                          |
|------------------|-----------------------|------------------------------------------------------|
| `TAG_Byte`       | `NBTByte`             | Subclass of `NSNumber`, init with `NBTByte(n)`       |
| `TAG_Short`      | `NBTShort`            | Subclass of `NSNumber`, init with `NBTShort(n)`      |
| `TAG_Int`        | `NBTInt`              | Subclass of `NSNumber`, init with `NBTInt(n)`        |
| `TAG_Long`       | `NBTLong`             | Subclass of `NSNumber`, init with `NBTLong(n)`       |
| `TAG_Float`      | `NBTFloat`            | Subclass of `NSNumber`, init with `NBTFloat(n)`      |
| `TAG_Double`     | `NBTDouble`           | Subclass of `NSNumber`, init with `NBTDouble(n)`     |
| `TAG_Byte_Array` | `NSMutableData`       |                                                      |
| `TAG_String`     | `NSString`            |                                                      |
| `TAG_List`       | `NSMutableArray`      |                                                      |
| `TAG_Compound`   | `NSMutableDictionary` |                                                      |
| `TAG_Int_Array`  | `NBTIntArray`         | Similar to `NSMutableData`, holds `int32_t` values   |

### Numeric Types
Numeric types are subclasses of `NSNumber`, so they all support `intValue`, `floatValue`, etc, but they
should be instantiated with the macros of the same name. They are implemented as different subclasses
so they maintain the same NBT tag type after saving.

### Collection Types
Collection types are kept mutable when reading for convenience, but they are not required to be mutable when writing.

### NBTIntArray
This class represents a mutable array of integers (`int32_t` values). It has similar features to `NSMutableData`.

## Reading NBT
`NBTKit` has the following class methods for reading NBT from files, streams or NSData objects:

    + (NSMutableDictionary*)NBTWithData:(NSData *)data name:(NSString **)name options:(NBTOptions)opt error:(NSError **)error;
    + (NSMutableDictionary*)NBTWithFile:(NSString *)path name:(NSString **)name options:(NBTOptions)opt error:(NSError **)error;
    + (NSMutableDictionary*)NBTWithStream:(NSInputStream *)stream name:(NSString **)name options:(NBTOptions)opt error:(NSError **)error;

* `data`, `path`, `stream`: NBT to read.
* `name`: This pointer is set to the name of the root tag. Pass `NULL` if not needed.
* `opt`: A combination of `NBTOptions` or zero. Valid options for reading are `NBTCompressed` and `NBTLittleEndian`
* `error`: If an error occurs, this pointer is set to an error object containing the error information. Pass `NULL` if not needed.
* returns a `NSMutableDictionary` with the NBT's root tag, or `nil` if an error occurs.


## Writing NBT
`NBTKit` has the following class methods for writing NBT to files, streams or NSData objects:

    + (NSData *)dataWithNBT:(NSDictionary*)base name:(NSString*)name options:(NBTOptions)opt error:(NSError **)error;
    + (NSInteger)writeNBT:(NSDictionary*)base name:(NSString*)name toStream:(NSOutputStream *)stream options:(NBTOptions)opt error:(NSError **)error;
    + (NSInteger)writeNBT:(NSDictionary*)base name:(NSString*)name toFile:(NSString *)path options:(NBTOptions)opt error:(NSError **)error;

* `base`: Root tag.
* `name`: Name of the root tag, or `nil` for no name.
* `stream`, `path`: Destination for the NBT data.
* `opt`: A combination of `NBTOptions` or zero. To write with Zlib compression, you must use both `NBTCompressed` and `NBTUseZlib` options.
* `error`: If an error occurs, this pointer is set to an error object containing the error information. Pass `NULL` if not needed.
* returns a `NSData` object with the written data, or the number of bytes written

You can also check whether an object is valid for writing to NBT:

    + (BOOL)isValidNBTObject:(id)obj;

Valid objects are:

* `NSDictionary` with `NSString` keys
* `NSArray` with valid objects of the same type, or empty
* `NSString`
* `NSData`
* `NBTIntArray`
* NBTKit Numbers: `NBTByte`, `NBTShort`, `NBTInt`, `NBTLong`, `NBTFloat`, `NBTDouble`

## Usage Example

    #import <NBTKit/NBTKit.h>
    
    [...]
    
    // read level.dat
    NSString *levelPath = [@"~/Library/Application Support/minecraft/saves/Project 1845/level.dat" stringByExpandingTildeInPath];
    NSMutableDictionary *levelDat = [NBTKit NBTWithFile:levelPath name:NULL options:NBTCompressed error:NULL];
    
    // set game rules
    levelDat[@"Data"][@"GameRules"] = @{
        @"commandBlockOutput": @"true",
        @"doDaylightCycle": @"true",
        @"doFireTick": @"false",
        @"doMobLoot": @"false",
        @"doMobSpawning": @"false",
        @"doTileDrops": @"true",
        @"keepInventory": @"true",
        @"mobGriefing": @"false"
    };
    
    // set other values
    levelDat[@"Data"][@"MapFeatures"] = NBTByte(0);
    levelDat[@"Data"][@"allowCommands"] = NBTByte(1);
    
    // write file
    [NBTKit writeNBT:levelDat name:nil toFile:levelPath options:NBTCompressed error:NULL];

## Region Files
NBTKit also supports reading and writing region files (.mcr and .mca), using the `MCRegion` class.

A `MCRegion` object represents a region file:

    + (instancetype)mcrWithFileAtPath:(NSString*)path;
    - (instancetype)initWithFileAtPath:(NSString*)path;

If the file doesn't exist, it will create an empty region file.

Chunks can be read and written using their positions in the region file (x and z from 0 to 31):

    - (NSMutableDictionary*)getChunkAtX:(NSInteger)x Z:(NSInteger)z;
    - (BOOL)setChunk:(NSDictionary*)root atX:(NSInteger)x Z:(NSInteger)z;

* `getChunkAtX:Z:` Will return `nil` if the chunk is not present in the region file.
* Pass `nil` to `setChunk:atX:Z:` to remove a chunk from the region file.

