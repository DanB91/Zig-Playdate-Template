# Visual Studio Code Launch Configurations for Debugging


These files should provide the minimum you need for debugging your Playdate game in Visual Studio Code. Each `launch.json` is platform specific. The `launch.macos.json` is the one for macOS, `launch.windows.json` is for Windows, etc.  `tasks.json` is the same for all platforms.

If you have not yet created a `launch.json` for your project yet and you are using this template as your project directory, the simplest way to use these files is:

```bash
mkdir ../.vscode
cp tasks.json ../.vscode/
cp launch.<your_platform>.json ../.vscode/
```

And now you should be able to go to `Run and Debug` and hit the green play button, or, just hit `F5` and your game will compile and launch!

__NOTE:__ Once you copy the configuration files in, or if you don't use Visual Studio Code, feel free to delete this directory.