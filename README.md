# macRCM
Swift-Made macOS RCM Payload Injector for Nintendo Switch

## Installation
1. Download the .zip
2. Move the .app to your Applications folder (or any other folder)
3. Run the app, plug your Switch in RCM Mode.

## Background Mode
Select the payload with the Documents icon next to background mode, clear it with the cross.
Sandbox limitation - You have to reselect your file every time you start the app. I'm trying a way around it but for now it's the only way

Please ensure to not delete the selected background payload at it's path

## Contributing / Building
1. Build a copy of [nxboot](https://github.com/mologie/nxboot)
2. Put the Apple Silicion and x86 binaries in Binaries folder in Xcode
3. you are good to go!

## Credits
- [nxboot (GPLv3)](https://github.com/mologie/nxboot)
- [LaunchAtLogin-Modern (MIT)](https://github.com/sindresorhus/LaunchAtLogin-modern)
