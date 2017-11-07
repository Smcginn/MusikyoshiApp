# First-stage-trumpet

## Post {pull,clone} instructions

0. Execute `scripts/unzip_frameworks.sh` to unzip the compressed SeeScoreLib
    frameworks. (You can also setup a git hook if you are so inclined.)
0. Execute `carthage update --platform iOS`. (You can install carthage using [Homebrew](https://brew.sh).)
0. Open `FirstStage.xcodeproj` in Xcode, and set your team in Project -> General -> Team for FirstStage{,-debug} targets
