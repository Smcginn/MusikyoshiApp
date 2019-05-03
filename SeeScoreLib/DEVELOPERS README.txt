
The SeeScore framework files must be downloaded from GoogleDrive and unzipped. The app will not build until you perform this step.

For this release, you want Version 330.

The framework libraries are in the MusiKyoshi Google Drive. You will need to contact Shawn for access to this drive if you don't already have it.

You must download the framework zip files (there are two), place them in the corresponding directories (this is very important!), and unzip them.

The framework files are in the Google Drive under Developer Resources as follows:

GoogleDrive/
... Developer Resources/
...... SeeScore/
......... Version 330/
............ AppStore-Release Framework/
............... AppStore-Release SeeScoreLib.framework.zip
............ Universal Framework/
............... Universal SeeScoreLib.framework.zip

Again, for this release, you want Version 330.

When you are done, your folders, on your Mac, should look like this:

... <app main folder>
...... SeeScoreLib
......... AppStore-Release
............ AppStore-Release-SeeScoreLib.framework.zip
............ DEVELOPERS README AppStore-Release.txt
............ SeeScoreLib.framework
............... Headers    	<folder with contents>
............... info.plist  
............... Modules    	<folder with contents>
............... SeeScoreLib    	
..........DEVELOPERS README.txt
......... Source		<folder with contents>
......... Synth-samples		<folder with contents>
......... Universal
............ DEVELOPERS README Universal.txt
............ SeeScoreLib.framework
............... Headers    	<folder with contents>
............... info.plist  
............... Modules    	<folder with contents>
............... SeeScoreLib    	
............ Universal-SeeScoreLib.framework.zip

NOTE: DO NOT INCLUDE ANY OF THESE DOWNLOADED ZIP OR UNZIPPED FILES IN A GIT COMMIT. These are excluded in gitignore, and shouldn't show up. If they do, don't do it.




Detailed Explanation

SeeScore is a third party Library we include in PlayTunes, and it is not available using GitHub, Carthage, CocoaPods, etc. So after we obtain the new release from SeeScore, we need to store the relevant parts of the library directly in our repo.

One of these files is the actual framework, SeeScoreLib.framework. There are actually two of these, and which one is used in the linking phase depends on the target platform (e.g., if app is being built for use in an iOS device or the simulator): 

- AppStore-Release: a stripped-down version of the framework, only including the binaries for running on an actual device

- Universal: includes binaries for running on an iOS device and in the simulator (which requires the same binaries as any app built to run on the Mac, not an iOS device)

Prior to SeeScore version 330, we were able to zip up these framework libraries and include them as part of a GitHub push to origin. However, for for files submitted within a commit, GitHub restricts individual file sizes to 100MB. 

As of SeeScore v330, the zipped version of the Universal framework library exceeds 100MB, and the upload to the GitHub repo is not allowed. GitHub’s suggestion for how to handle this is to use include links to an external storage, such as DropBox, Google Drive, etc.

Even though the AppStore-Release framework is still small enough to include in a commit, I decided to put both up on the Google Drive to avoid possible confusion.

Scott Freshour - 5/2/2019