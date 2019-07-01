# ElvUI Updater

This project is a Powershell script that is able to be automatically update ElvUI from the vendor's download page on Windows. This project exists so that I can auto update my girlfriend's and my ElvUI without the TukUI client since ElvUI isn't available through any of the normal auto-updating channels.

## How to use
Here is an example of how this script is used:

```
PS E:\p\elvui-updater> .\updater.ps1 -InstallPath "G:\Blizzard\World of Warcraft\_retail_\Interface\addons"
Checking for elvui updates
The download href is https://www.tukui.org/downloads/elvui-11.14.zip
The newest file is elvui-11.14.zip
```

## Scheduled task
Instead of manually running the script, you can put this into a scheduled task that runs periodically. The easiest way I know to do this is by creating a basic scheduled task and starting `powershell.exe` with the following arguments:

`-ExecutionPolicy Unrestricted "c:\path\to\updater.ps1" -InstallPath "'C:\Program Files (x86)\World of Warcraft\_retail_\Interface\addons'"`

> Please note the inner quotation marks in the arguments above. These are necessary at this time to allow spaces in the InstallPath.

## Notes
I hope this is useful. Please feel free to submit pull requests with improvements and we can review.
