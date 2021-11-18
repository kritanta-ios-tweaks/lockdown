#include "KLockdownClient.h"
#include "MRYIPCCenter.h"

@implementation KLockdownClient {
    MRYIPCCenter *_center;
}

+ (void)load
{
	[self sharedInstance];
}

+ (id)sharedInstance
{
	static dispatch_once_t once = 0;
	__strong static id sharedInstance = nil;

	dispatch_once(&once, ^{
		sharedInstance = [[self alloc] init];
	});
    
	return sharedInstance;
}


- (id)init
{
	if ((self = [super init]))
	{
		_center = [MRYIPCCenter centerNamed:@"me.krit.lockdownserver"];
	}

	return self;
}

- (void)lock 
{
    [_center callExternalVoidMethod:@selector(lock) withArguments:@{}];
}

- (BOOL)isPasscodeEnabled
{
    NSDictionary *reply = [_center callExternalMethod:@selector(passcodeMetadata) withArguments:@{}];

    return [reply[@"s"] boolValue];
}

- (BOOL)isPasscodeNumeric 
{
    NSDictionary *reply = [_center callExternalMethod:@selector(passcodeMetadata) withArguments:@{}];

    return [reply[@"n"] boolValue];
}

- (BOOL)isDeviceUnlocked
{

    NSDictionary *reply = [_center callExternalMethod:@selector(status) withArguments:@{}];
    NSDictionary *reply2 = [_center callExternalMethod:@selector(passcodeMetadata) withArguments:@{}];

    if (![reply2[@"s"] boolValue])
        return YES;

    return ([reply[@"u"] boolValue]);
}

- (NSUInteger)passcodeLength
{
    NSDictionary *reply = [_center callExternalMethod:@selector(passcodeMetadata) withArguments:@{}];

    return [reply[@"l"] intValue];
}

- (BOOL)attemptUnlockWithPasscode:(NSString *)passcode
{
    [_center callExternalVoidMethod:@selector(attemptUnlockWithPasscode:) withArguments:@{@"passcode":passcode}];

    return [self isDeviceUnlocked];
}

- (BOOL)changePasscodeFrom:(NSString *)oldPasscode to:(NSString *)newPasscode
{
    if (!oldPasscode)
        oldPasscode = @"KNULLPASSCODE";
    if (!newPasscode)
        newPasscode = @"KNULLPASSCODE";
    NSDictionary *reply = [_center callExternalMethod:@selector(changePasscode:) withArguments:@{@"from":oldPasscode, @"to":newPasscode}];

    return [reply[@"success"] boolValue];
}

@end