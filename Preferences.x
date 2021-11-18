
#include "libksecure/KLockdownClient.h"

@interface DevicePINController : NSObject 

- (BOOL)isCreatingPasscode;

@end

%hook DevicePINController

- (BOOL)numericPIN
{
    if ([self isCreatingPasscode])
        return %orig();

    return [[KLockdownClient sharedInstance] isPasscodeNumeric];

}

- (BOOL)simplePIN
{
    if ([self isCreatingPasscode])
        return %orig();
    
    if ([[KLockdownClient sharedInstance] passcodeLength] == 4 || [[KLockdownClient sharedInstance] passcodeLength] == 6)
    {
        if ([[KLockdownClient sharedInstance] isPasscodeNumeric])
            return YES;
    }
    return NO;
}

- (int)pinLength
{
    if ([self isCreatingPasscode])
        return %orig();
    
    return [[KLockdownClient sharedInstance] passcodeLength];
}

%end
