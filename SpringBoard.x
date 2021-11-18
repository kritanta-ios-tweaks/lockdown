#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include "libksecure/KLockdownClient.h"

@interface KPreferenceServer : NSObject 
+ (void)load;
@end


typedef enum LKDPasscodeStyle : NSUInteger {
  kFourDigitPasscodeStyle,
  kSixDigitPasscodeStyle,
  kCustomNumericPasscodeStyle,
  kCustomPasscodeStyle
} LKDPasscodeStyle;

@interface SBFAuthenticationRequest : NSObject

@property (readonly, nonatomic) NSUInteger type; // ivar: _type
@property (readonly, nonatomic) NSInteger source; // ivar: _source
@property (readonly, copy, nonatomic) NSString *passcode; // ivar: _passcode
@property (readonly, copy, nonatomic) id handler; // ivar: _handler

-(id)publicDescription;
-(id)descriptionWithMultilinePrefix:(id)arg0 ;
-(id)succinctDescription;
-(id)descriptionBuilderWithMultilinePrefix:(id)arg0 ;
-(id)succinctDescriptionBuilder;
-(id)description;
-(id)initForBiometricAuthenticationWithSource:(NSInteger)arg0 ;

@end

NSInteger passcodeStyleForUser()
{
  if ([[KLockdownClient sharedInstance] isPasscodeNumeric])
  {
    switch ([[KLockdownClient sharedInstance] passcodeLength]) {
      case 4:
          return kFourDigitPasscodeStyle;
      case 6:
          return kSixDigitPasscodeStyle;
      default:
          return kCustomNumericPasscodeStyle;
    }
    
  }
  return kCustomPasscodeStyle;
}

BOOL userHasPasscodeEnabled()
{
  return [[KLockdownClient sharedInstance] isPasscodeEnabled];
}

BOOL shouldUnlockDevice()
{
  return [[KLockdownClient sharedInstance] isDeviceUnlocked];
}

NSInteger SBUICurrentPasscodeStyleForUser();

%hookf(NSInteger, SBUICurrentPasscodeStyleForUser)
{
  return passcodeStyleForUser();
}

%hook SBFUserAuthenticationController

- (BOOL) hasPasscodeSet 
{
  return userHasPasscodeEnabled();
}

-(BOOL)_isUserAuthenticated 
{
  return shouldUnlockDevice();
}

%end

%hook SBLockScreenManager

-(void)_handleBacklightDidTurnOff:(id)arg0
{
  [[KLockdownClient sharedInstance] lock];

  %orig(arg0);
}

%end

%hook SBFMobileKeyBag

- (BOOL)unlockWithPasscode:(id)passcode error:(id *)error
{
  return [[KLockdownClient sharedInstance] attemptUnlockWithPasscode:passcode];
}

%end
