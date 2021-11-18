#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>

#include "device.m"

#define NO_KEYBAG_VERSION 0
#define INITIAL_BETA_KEYBAG_VERSION 1
#define CURRENT_KEYBAG_VERSION 2


NSString *sha256HashForText(NSString *text) {
    const char* utf8chars = [text UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(utf8chars, (CC_LONG)strlen(utf8chars), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

NSString *hexStringForNSData(NSData *data) {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */

    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];

    if (!dataBuffer)
        return [NSString string];

    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];

    return [NSString stringWithString:hexString];
}

NSData *dataForHexString(NSString *string) {
  NSMutableData* data = [NSMutableData data];
  int idx;
  for (idx = 0; idx+2 <= string.length; idx+=2) {
    NSRange range = NSMakeRange(idx, 2);
    NSString* hexStr = [string substringWithRange:range];
    NSScanner* scanner = [NSScanner scannerWithString:hexStr];
    unsigned int intValue;
    [scanner scanHexInt:&intValue];
    [data appendBytes:&intValue length:1];
  }
  return data;
}

typedef struct LKD_HEADER {
    uint32_t magic; // 4b 4c 4b 44
    uint32_t version; // 
    uint32_t flags;
    uint32_t passcodeLength;
    uint32_t reserved0;
    uint32_t reserved1;
    uint32_t reserved2;
    uint32_t reserved3;
} LKD_HEADER;

typedef struct LKD_KEYBAG {
    LKD_HEADER header; // 32 bytes (256 bits)
    char data[64];
} LKD_KEYBAG;

#define LKD_PASSCODE_SET 0x1
#define LKD_PASSCODE_IS_NUMERIC 0x2
#define LKD_PASSCODE_IS_ALPHANUMERIC 0x4


LKD_KEYBAG initializedKeybag()
{
    LKD_HEADER newHeader;
    newHeader.magic = 0x4b4c4b44;
    newHeader.version = CURRENT_KEYBAG_VERSION;
    newHeader.flags = 0;
    newHeader.passcodeLength = 0;

    char dataArray[64];

    LKD_KEYBAG newKeybag;
    newKeybag.header = newHeader;
    strcpy(dataArray, newKeybag.data);

    return newKeybag;
}


LKD_KEYBAG keybagWithData(NSData *data)
{
    LKD_HEADER header;
    [data getBytes:&header range:NSMakeRange(0, 32)];

    NSData *dataItem = [data subdataWithRange:NSMakeRange(32, 64)];
    NSString *dataString = hexStringForNSData(dataItem);

    char dataArray[64];
    [dataString getCString:dataArray maxLength:64 encoding:NSASCIIStringEncoding];

    LKD_KEYBAG keybag;
    keybag.header = header;
    strcpy(dataArray, keybag.data);

    return keybag;
}

NSData *dataWithKeybag(LKD_KEYBAG keybag)
{
    NSMutableData *header = [NSMutableData dataWithBytes:&keybag.header length:sizeof(keybag.header)];

    NSString* dataString = [[NSString alloc] initWithCString:keybag.data encoding:NSASCIIStringEncoding];
    NSData *data = dataForHexString(dataString);

    [header appendData:data];

    return [NSData dataWithData:header];
}



