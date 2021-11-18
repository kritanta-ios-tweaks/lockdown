#include <Foundation/Foundation.h>

@interface KLockdownKeybag : NSObject

@property NSUInteger needsUpdateFromKeybagVersion;

@property NSString *encodedData;

- (NSData *)keybagData;
-(instancetype)init;

- (BOOL)testPasscode:(NSString *)passcode; 
- (BOOL)changePasscodeFrom:(NSString *)oldPasscode to:(NSString *)newPasscode;

- (BOOL)passcodeIsNumeric;
- (BOOL)passcodeLength;
- (BOOL)passcodeIsSet;

@end