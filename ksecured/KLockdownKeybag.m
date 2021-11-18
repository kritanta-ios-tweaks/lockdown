#include "KLockdownKeybag.h"

#include "KLockdownDataSerialization.m"

#include "MRYIPCCenter.h"

static BOOL updating = NO;

@implementation KLockdownKeybag {
    LKD_KEYBAG _keybag;
}

+ (BOOL)isStringNumeric:(NSString *)text
{
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:text];        
    return [alphaNums isSupersetOfSet:inStringSet];
}

- (NSData *)keybagData
{
    return dataWithKeybag(_keybag);
}

-(instancetype)init
{
    
	if ((self = [super init]))
	{   
        NSData *keybagData = nil;

        if (!keybagData)
        {
            _keybag = initializedKeybag();
            
        }
        else 
        {
            _keybag = keybagWithData(keybagData);

            self.encodedData = [[NSString alloc] initWithCString:_keybag.data encoding:NSASCIIStringEncoding];
        }
    }

    return self;
}

- (void)updateKeybag:(LKD_KEYBAG)keybag 
{
    NSData *keybagData = dataWithKeybag(keybag);

    _keybag = keybag;

    self.encodedData = [[NSString alloc] initWithCString:_keybag.data encoding:NSASCIIStringEncoding];
}

- (BOOL)testPasscode:(NSString *)passcode 
{

    if (!passcode)
    {
        if ((_keybag.header.flags & LKD_PASSCODE_SET) == 0)
        {
            /*
            This is mainly for changePasscodeFrom:to:, if the provided passcode is null, 
            and no passcode is set, return true
            */
            return YES; 
        }
        // Otherwise return false.
        return NO;
    }
    NSString *a = IAEWSPFJPASAPJ();
    NSString *match = sha256HashForText([NSString stringWithFormat:@"%@%@", a, passcode]);

    return [self.encodedData isEqualToString:match];
}

- (BOOL)changePasscodeFrom:(NSString *)oldPasscode to:(NSString *)newPasscode
{
    BOOL passed = [self testPasscode:oldPasscode];

    if (!passed) // Passcode Entry Failed
        return NO;

    if (!newPasscode)
    {
        // Disabling passcode
        [self updateKeybag:initializedKeybag()];
        return YES;
    }
    
    NSString *a = IAEWSPFJPASAPJ();
    NSString *newEncodedDataString = sha256HashForText([NSString stringWithFormat:@"%@%@", a, newPasscode]);

    LKD_HEADER newHeader;
    newHeader.magic = 0x4b4c4b44;
    newHeader.version = CURRENT_KEYBAG_VERSION;
    newHeader.passcodeLength = [newPasscode length];
    int flags = LKD_PASSCODE_SET;

    if ([KLockdownKeybag isStringNumeric:newPasscode])
        flags = flags | LKD_PASSCODE_IS_NUMERIC;
    else 
        flags = flags | LKD_PASSCODE_IS_ALPHANUMERIC;
    
    char dataArray[64];
    
    [newEncodedDataString getCString:dataArray maxLength:64 encoding:NSASCIIStringEncoding];

    LKD_KEYBAG keybag;
    keybag.header = newHeader;
    strcpy(dataArray, keybag.data);
    
    [self updateKeybag:keybag];
    return YES;
}

- (BOOL)passcodeIsNumeric
{
    return _keybag.header.flags & LKD_PASSCODE_IS_NUMERIC;
}
- (BOOL)passcodeLength
{
    return _keybag.header.passcodeLength;
}
- (BOOL)passcodeIsSet
{
    return _keybag.header.flags & LKD_PASSCODE_SET;
}

@end