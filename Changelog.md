#  Changelog

*Insert new entries **above** previous ones*

## 2017-11-06 : Matt Lewin
- Fix a bug in `SSScrollView.m` where the view's frame was being updated on a background thread
- Remove `AudioKit.framework` from the repo in favor of using [Carthage](https://github.com/Carthage/Carthage) to build it. (I *did* pin
    `AudioKit` to version 3.6, to preserve whatever existing API the project relied upon.) This eases the transition across various versions of
    Swift (at least until ABI is implemented in Swift).
- Update `FirstStage.xcodeproj` to use Swift version 3.2 (because Xcode 9 left us no choice).
- Update deployment target to iOS 10.3, because `AudioKit` seemed to require it. (This is likely the result of the way I configured Carthage
    to build it. If we do need to support iOS 9, I can figure out how to make that happen.)
- Add `scripts/unzip_frameworks.sh` to ease the initial cloning and building process
- Update and reformat the README
- Add this Changelog. 😉
