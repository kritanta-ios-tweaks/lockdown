#include <Foundation/Foundation.h>
#include "libksecure/KLockdownClient.h"

/* 
These hooks are mainly related to the Preferences executable

They intercept both passcode changing and passcode checking

This prevents the device from invoking the SEP and rebooting when a passcode change is requested

This also allows the KPasscodeClient to save/load passcodes
*/

%hook MCProfileConnection

-(BOOL)isPasscodeSet
{
    return [[KLockdownClient sharedInstance] isPasscodeEnabled];
}

-(BOOL)unlockDeviceWithPasscode:(NSString *)passcode outError:(id *)arg1
{
    return [[KLockdownClient sharedInstance] attemptUnlockWithPasscode:passcode];
}

-(BOOL)changePasscodeFrom:(id)arg0 to:(id)arg1 outError:(id *)arg2 
{
    return [[KLockdownClient sharedInstance] changePasscodeFrom:arg0 to:arg1];
}

%end