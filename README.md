# lockdown

I can't remember if this version (involving ksecured) is actually functioning, Started working on this right before I moved, haven't really worked on it much since. 

But hey, if you want to work on your own version of this tweak (that's better and all that), *please* do!

---

This tweak barely requires any hooks, it just requires carefully chosen locations to do them.

`ManagedConfiguration.x` is injected into everything that links this framework.

by hooking a few methods in `MCProfileConnection`, we're able to intersect passcode setting before it ever gets anywhere even close to panicking the SEP. 

We also hook the isPasscodeSet method, which fixes the "is passcode enabled" checks in multiple locations (including Preferences.app!)

---

`Preferences.x` is injected into the settings app.

All we need to hook in Preferences is `DevicePINController`. This is the popup that appears when setting/entering a passcode. 

We just hook specific checks it makes on passcode constraints so the pin controller pops up with the proper constraints.

---

`SpringBoard.x` is injected into, you guessed it, SpringBoard.app

We only have 5 hooks here, just to ensure our own daemon knows the device is locked, catch the unlock attempts, and update passcode constraints.