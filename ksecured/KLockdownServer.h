#include <Foundation/Foundation.h>
#include "KLockdownKeybag.h"

@interface KLockdownServer : NSObject

@property KLockdownKeybag *temp;

+(void)load;
+(id)sharedInstance;

@end