//
//  MCRegion.m
//  NBTKit
//
//  Created by Jesús A. Álvarez on 30/11/2013.
//  Copyright (c) 2013 namedfork. All rights reserved.
//

#import "NBTKit.h"
#import "MCRegion.h"

@implementation MCRegion
{
    NSFileHandle *fileHandle;
}

- (instancetype)initWithFileAtPath:(NSString *)path
{
    int fd = open(path.fileSystemRepresentation, O_CREAT | O_RDWR);
    if (fd < 0) return nil;
    NSFileHandle *fh = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
    // if the file exists, it must be a valid mcr
    if (![self _checkHeader]) return nil;
    
    if ((self = [super init])) {
        fileHandle = fh;
    }
    return self;
}

+ (instancetype)mcrWithFileAtPath:(NSString *)path
{
    return [[self alloc] initWithFileAtPath:path];
}

// returns root tag or nil
- (id)_readChunk:(NSUInteger)num
{
    return [NBTKit NBTWithData:[self _readChunkData:num] name:NULL options:NBTCompressed error:NULL];
}

- (NSDate*)_chunkTimestamp:(NSUInteger)num
{
    // read chunk timestamp
    [fileHandle seekToFileOffset:4096 + 4*num];
    NSData *timestampData = [fileHandle readDataOfLength:4];
    if (timestampData.length != 4) return nil;
    return [NSDate dateWithTimeIntervalSince1970:OSReadBigInt32(timestampData.bytes, 0)];
}

- (NSData*)_readChunkData:(NSUInteger)num
{
    @synchronized(self) {
        // read chunk offset and size
        [fileHandle seekToFileOffset:4*num];
        NSData *loc = [fileHandle readDataOfLength:4];
        if (loc.length != 4) return nil; // no header - is this a new file?
        uint8_t *buf = (uint8_t*)loc.bytes;
        int offset = (buf[0] << 16) | (buf[1] << 8) | buf[2];
        int sectors = buf[3];
        if (offset == 0 || sectors == 0) return nil; // chunk not present
        
        // read actual length and compression type
        [fileHandle seekToFileOffset:offset * 4096];
        NSData *chunkHeader = [fileHandle readDataOfLength:5];
        int32_t chunkLength = OSReadBigInt32(chunkHeader.bytes, 0);
        // compression can be ignored
        NSData *chunkData = [fileHandle readDataOfLength:chunkLength-1];
        return chunkData;
    }
}

- (BOOL)_checkHeader
{
    // check header exists
    [fileHandle seekToEndOfFile];
    unsigned long long fileSize = fileHandle.offsetInFile;
    if (fileSize == 0) return YES; // empty file is valid
    if (fileSize < 8192 || fileSize % 4096 != 0) return NO; // file must have 8K header, and be multiple of 4K (sector size)
    
    // read header
    [fileHandle seekToFileOffset:0];
    int maxSectors = 2;
    NSData *header = [fileHandle readDataOfLength:4096];
    for (NSUInteger i=0; i < 1024; i++) {
        uint32_t loc = OSReadBigInt32(header.bytes, 4*i);
        int offset = loc >> 8;
        int sectors = loc & 0xFF;
        maxSectors = MAX(maxSectors, offset+sectors);
    }
    
    // check that file has all sectors
    return maxSectors <= fileSize / 4096;
}

- (BOOL)_writeChunk:(NSUInteger)num root:(NSDictionary*)root
{
    // compress data
    NSData *chunkData = [NBTKit dataWithNBT:root name:NULL options:NBTCompressed+NBTUseZlib error:NULL];
    NSUInteger chunkSectors = (chunkData.length+5+4095) / 4096;
    if (chunkSectors > 255) return NO;
    
    @synchronized(self) {
        if (root == nil || root.count == 0) return [self _writeChunkAllocation:num range:NSMakeRange(0, 0)];
        
        // ensure there's a MCR header
        [fileHandle seekToEndOfFile];
        if (fileHandle.offsetInFile < 8192) [fileHandle truncateFileAtOffset:8192];
        
        // read sector allocation map
        NSMutableData *allocationMap = [NSMutableData dataWithLength:fileHandle.offsetInFile/4096];
        uint8_t *map = (uint8_t*)allocationMap.bytes;
        memcpy(map, "xx", 2); // mark blocks occupied by header
        [fileHandle seekToFileOffset:0];
        NSData *header = [fileHandle readDataOfLength:4096];
        for (NSUInteger i=0; i < 1024; i++) {
            if (i == num) continue; // don't read allocation for this chunk
            uint32_t loc = OSReadBigInt32(header.bytes, 4*i);
            int offset = loc >> 8;
            int sectors = loc & 0xFF;
            // mark used blocks
            for (int b=0; b < sectors; b++) map[offset+b] = 'x';
        }
        
        // add empty space at end for this chunk, in case it's needed
        allocationMap.length += chunkSectors;
        
        // find empty space
        NSRange chunkRange = [allocationMap rangeOfData:[NSMutableData dataWithLength:chunkSectors] options:0 range:NSMakeRange(0, allocationMap.length)];
        if (chunkRange.location == NSNotFound) return NO; // this shouldn't happen
        
        // write chunk
        uint8_t chunkHeader[5];
        OSWriteBigInt32(chunkHeader, 0, chunkData.length+1);
        chunkHeader[4] = 2; // zlib compression
        [fileHandle seekToFileOffset:4096 * chunkRange.location];
        [fileHandle writeData:[NSData dataWithBytesNoCopy:chunkHeader length:5 freeWhenDone:NO]];
        [fileHandle writeData:chunkData];
        
        // padding if needed
        [fileHandle seekToEndOfFile];
        if (fileHandle.offsetInFile % 4096 != 0) {
            [fileHandle truncateFileAtOffset:(fileHandle.offsetInFile + 4095) &~ 4095ULL];
        }
        
        return [self _writeChunkAllocation:num range:chunkRange];
    }
}

- (BOOL)_writeChunkAllocation:(NSUInteger)num range:(NSRange)chunkRange
{
    // write allocation in header
    uint8_t buf[4];
    OSWriteBigInt32(buf, 0, chunkRange.location << 8 | chunkRange.length);
    [fileHandle seekToFileOffset:4*num];
    [fileHandle writeData:[NSData dataWithBytes:buf length:4]];
    
    // write timestamp
    OSWriteBigInt32(buf, 0, chunkRange.length ? time(NULL) : 0);
    [fileHandle seekToFileOffset:4096 + 4*num];
    [fileHandle writeData:[NSData dataWithBytes:buf length:4]];
    
    return YES;
}

- (NSMutableDictionary*)getChunkAtX:(NSInteger)x Z:(NSInteger)z
{
    if (x < 0 || z < 0 || x > 31 || z > 31) return nil;
    return [self _readChunk:x + z*32];
}

- (BOOL)setChunk:(NSDictionary*)root atX:(NSInteger)x Z:(NSInteger)z
{
    if (x < 0 || z < 0 || x > 31 || z > 31) return NO;
    if (root && ![NBTKit isValidNBTObject:root]) return NO;
    return [self _writeChunk:x + z*32 root:root];
}

- (NSInteger)rewrite
{
    NSInteger savedSize = 0;
    @synchronized(self) {
        // get current size
        [fileHandle seekToEndOfFile];
        unsigned long long oldSize = fileHandle.offsetInFile;
        
        // read all chunks and check sizes
        NSMutableDictionary *chunks = [NSMutableDictionary dictionaryWithCapacity:1024];
        NSMutableDictionary *timestamps = [NSMutableDictionary dictionaryWithCapacity:1024];
        for (NSUInteger i=0; i < 1024; i++) {
            NSData *chunkData = [self _readChunkData:i];
            if (chunkData) {
                chunks[@(i)] = chunkData;
                timestamps[@(i)] = [self _chunkTimestamp:i];
            }
        }
        
        // write the whole file
        [fileHandle truncateFileAtOffset:0];
        
        // header
        NSMutableData *header = [NSMutableData dataWithLength:8192];
        
        // write chunks
        NSUInteger curSector = 2;
        [fileHandle seekToFileOffset:8192];
        for (NSUInteger i=0; i < 1024; i++) {
            NSData *chunkData = chunks[@(i)];
            if (chunkData == nil) continue; // missing chunk
            
            // set header
            NSUInteger chunkSectors = (chunkData.length+5+4095) / 4096;
            OSWriteBigInt32(header.mutableBytes, 4*i, curSector << 8 | chunkSectors);
            OSWriteBigInt32(header.mutableBytes+4096, 4*i, (int32_t)[timestamps[@(i)] timeIntervalSince1970]);
            curSector += chunkSectors;
            
            // write chunk
            uint8_t chunkHeader[5];
            OSWriteBigInt32(chunkHeader, 0, chunkData.length+1);
            chunkHeader[4] = 2; // zlib compression
            [fileHandle writeData:[NSData dataWithBytesNoCopy:chunkHeader length:5 freeWhenDone:NO]];
            [fileHandle writeData:chunkData];
            
            // zero fill
            [fileHandle truncateFileAtOffset:(fileHandle.offsetInFile + 4095) &~ 4095ULL];
        }
        
        // get end size
        savedSize = oldSize - fileHandle.offsetInFile;
        
        // write header
        [fileHandle seekToFileOffset:0];
        [fileHandle writeData:header];
        [fileHandle synchronizeFile];
    }
    
    return savedSize;
}

- (BOOL)isEmpty
{
    @synchronized(self) {
        // check header
        [fileHandle seekToEndOfFile];
        if (fileHandle.offsetInFile < 8192) return YES;
        
        // read header
        [fileHandle seekToFileOffset:0];
        NSData *header = [fileHandle readDataOfLength:4096];
        for (NSUInteger i=0; i < 1024; i++) {
            uint32_t loc = OSReadBigInt32(header.bytes, 4*i);
            if (loc != 0) return NO; // there's a chunk
        }
    }
    
    return YES;
}

@end
