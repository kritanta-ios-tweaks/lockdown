@import Foundation;

@interface KLockdownClient : NSObject 

+ (void)load;
+ (id)sharedInstance;

- (void)lock;

- (BOOL)isPasscodeEnabled;
- (BOOL)isPasscodeNumeric;
- (BOOL)isDeviceUnlocked;
- (NSUInteger)passcodeLength;

- (BOOL)attemptUnlockWithPasscode:(NSString *)passcode;

- (BOOL)changePasscodeFrom:(NSString *)oldPasscode to:(NSString *)newPasscode;

@end