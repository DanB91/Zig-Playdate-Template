# Zig Template for Playdate

## Overview
Write your [Playdate](https://play.date) game in [Zig](https://ziglang.org)!  Use this template as a starting point to write your games in Zig.  The `build.zig` will allow you to generate a Playdate `.pdx` executable that will work both in the simulator and on hardware.

## Things To Be Aware Of
- Not Everything Has Been Tested
    - With `zig translate-c` and a bunch of customization by hand, I converted the C API of the Playdate SDK to Zig.  While I have battle tested a lot of the APIs in my upcoming Pictoblox game and in my [port of UPWARD](https://github.com/DanB91/Upward-for-Playdate), there is much of the API here that has not been tested -- especially, the Sprite, JSON, Synth, and Sound Effect APIs.  If something isn't working, please check against the headers in the Playdate SDK C API and make sure the APIs match. Please open a bug report if the APIs don't match.

- Not Officially Supported
    - While it works very well due to its interoperability with C, Zig is not officially supported on the Playdate.  If you are having any issues, feel free to open a bug report here.

- Be Mindful Of The Stack
    - You only get 10KB of stack space. That's it. I have not tested much of Zig's std on the Playdate, but std was not designed for a stack this small. See how far you can get, but you might want to write a lightweight "toolbox" library, like I did for UPWARD.  `std.fmt.bufPrintZ` works well, though!.

##  <a name="Requirements"></a>Requirements
- Either macOS, Windows, or Linux.
- Zig compiler 0.11.0-dev.3867+ff37ccd29 or newer. Pulling down the latest build is your best bet.
- [Playdate SDK](https://play.date/dev/) installed.

## Contents
- `build.zig` -- Prepopulated with code that will generate the Playdate `.pdx` executable.
- `src/playdate_api_definitions.zig` -- Contains all of the Playdate API code.  This is 1-to-1 with [Playdate's C API](https://sdk.play.date/2.0.0/Inside%20Playdate%20with%20C.html)
- `main.zig` -- Entry point for your code!  Contains example code that prints "Hello from Zig!" and an draws an example image to the screen.
- `assets/` -- This folder will contain your assets and has an example image that is drawn to the screen in the example code in `main.zig`.

## Run Example Code
1. Make sure the Playdate SDK is installed, Zig is installed and in your PATH, and all other [requirements](#Requirements) are met.
1. Make sure the Playdate Simulator is closed.
1. Run `zig build run`.
    1. If there any errors, double check `PLAYDATE_SDK_PATH` is correctly set.
1. You should now see simulator come up and look the [screenshot here](#Screenshot).
1. When you quit out to the home menu, change the home menu to view as list and you should see the "Hello World Zig" program with a custom icon [like here](#ListView).
1. Optionally, connect your Playdate to the comupter and upload to the device by going to `Device` -> `Upload Game to Device..` in the Playdate Simulator.
    1. It should load and run on the hardware as well!


## <a name="Screenshot"></a>Screenshot
<img src="readme_res/screenshot.png" alt="isolated" width="400"/>

## <a name="ListView"></a>Home Screen List View
<img src="readme_res/listview.png" alt="isolated" width="400"/>

