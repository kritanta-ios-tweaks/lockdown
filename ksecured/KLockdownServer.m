#include <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include "KLockdownServer.h"
#include "MRYIPCCenter.h"


@implementation KLockdownServer 
{
    MRYIPCCenter *_center;
    BOOL _unlocked;
    NSUInteger _failedUnlocks;
    KLockdownKeybag *_keybag;
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

- (void)attemptUnlockWithPasscode:(NSDictionary *)message
{
    BOOL test = [_keybag testPasscode:message[@"passcode"]];
    if (test)
    {
        _failedUnlocks = 0;
        _unlocked = YES;
    }
    else 
    {
        _failedUnlocks = _failedUnlocks + 1;
    }

}

- (void)lock
{
    _unlocked = NO;
}

- (NSDictionary *)status
{
    printf("Recieved Request for Lockdown Status");
    NSDictionary *reply = @{@"u":@(_unlocked)};

    return reply;
}

- (NSDictionary *)passcodeMetadata
{
    BOOL numeric = [_keybag passcodeIsNumeric];
    BOOL set = [_keybag passcodeIsSet];
    int length = [_keybag passcodeLength];

    NSDictionary *reply = @{@"n":@(numeric), @"s":@(set), @"l":@(length)};

    return reply;
}

- (NSDictionary *)changePasscode:(NSDictionary *)message
{
    NSString *from = message[@"from"];
    NSString *to = message[@"to"];

    if ([from isEqualToString:@"KNULLPASSCODE"])
        from = nil;
    if ([to isEqualToString:@"KNULLPASSCODE"])
        to = nil;

    BOOL attempt = [_keybag changePasscodeFrom:from to:to];

    NSDictionary *reply = @{@"success":@(attempt)};

    return reply;
}

- (KLockdownKeybag *)bag
{
    return _keybag;
}
 
- (id)init
{
	if ((self = [super init]))
	{
        _keybag = [[KLockdownKeybag alloc] init];
        self.temp = _keybag;

		_center = [MRYIPCCenter centerNamed:@"me.krit.lockdownserver"];

		[_center addTarget:self action:@selector(attemptUnlockWithPasscode:)];
		[_center addTarget:self action:@selector(changePasscode:)];

		[_center addTarget:self action:@selector(lock)];
		[_center addTarget:self action:@selector(status)];
		[_center addTarget:self action:@selector(passcodeMetadata)];
	}

	return self;
}


@end
