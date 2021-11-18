@import CoreFoundation;
@import Foundation;

#include "KLockdownServer.h"

int main(int argc, char** argv, char** envp)
{
	@autoreleasepool
	{
		[KLockdownServer load];

		NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
		for (;;)
			[runLoop run];
		return 0;
	}
}