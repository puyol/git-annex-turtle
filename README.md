# git-annex-turtle
*git-annex-turtle* provides Apple Finder integration, including badge icons, contextual menus and a Menubar icon (aka menubar extra) for [git-annex](http://git-annex.branchable.com/) on the Mac. It it a native Mac app written in Swift 4 with XCode 9.2.

*git-annex-turtle* is open-source, licensed under [The MIT License](https://opensource.org/licenses/MIT).

## Getting Started
### Install
Download and install [git-annex](http://git-annex.branchable.com/install/OSX/) for macOS. Follow the git-annex [walkthrough](http://git-annex.branchable.com/walkthrough/) if you have never used git-annex before.

Download and install git-annex-turtle.

### Usage
Click the git-annex-turtle Menubar icon, then click `Watch a repository`, select a git-annex repository to watch.

You are now all set. Open your git-annex repository in Apple Finder to see updated badge icons. Right click (control-click) on a file or folder to see git-annex specific context menus.

### Requirements
macOS or OS-X 10.10 (Yosemite) or later

*git-annex-turtle* relies on the Apple Finder Sync API so is only available on OS-X 10.10 (Yosemite) and later and all versions of macOS. The [Liferay Nativity](https://github.com/liferay/liferay-nativity) library could potentially be used to enable *git-annex-turtle* to run on older Mac OSs. 

*git-annex-turtle* is released for the the Mac only; it is written in Swift with XCode so is probably not easily portable to Linux and Windows. You may, of course, adapt and use this app's user experience, design, workflow and icon sets when porting to other OSs. See git-annex [related software](http://git-annex.branchable.com/related_software/) for options already built for other OSs.

## Name
*git-annex-turtle* takes inspiration in function and name from [TortoiseCVS](https://en.wikipedia.org/wiki/TortoiseCVS) and many other tools which have provided OS-level icons for source revisions control over the years.

## Build a Release
 * Open mac-experiments2/git-annex-turtle.xcodeproj in XCode 9.2
 * Click on the git-annex-turtle scheme (to the right of the triangle play button top of screen), click Edit Scheme, Make sure Run > Build Configuration is set to Release
 * Select the Scheme 'git-annex-turtle' then build: Product > Build 
 * You will find the .app in Open the ~/Library/Developer/Xcode/DerivedData/ directory and Look for git-annex-turtle-…/Build/Products/Release/git-annex-turtle.app

## TODO
 * replace hard-coded absolute paths to git-annex installation with more graceful solution  
 * gui for add/ remove watch
 * icons for present/absent num-copies 0…numcopies…9+
 * pre-fetch files in observed folders for faster badge updates
 * after a git annex get if we already have an item highlighted the Finder thumb preview doesn't update? possible to do that? or is there just a delay?
 * what icons to display for git files, staged, in a commit, unstaged, etc…, maybe copy what git annex status does
 * show file info in context menu with description of icon meaning
 * rename git-annex-finder process name to 'git-annex-turtle Finder'
 * rename git-annex-mac-cmd to 'git-annex-turtle-cli'
 * better logging? what do people use https://stackoverflow.com/questions/7512211/how-to-output-warnings-to-the-console-during-a-build-in-xcode
 * Monitor filesystem for changes? https://github.com/eonil/FileSystemEvents, https://github.com/njdehoog/Witness
 
## Internal: Tutorials, References, XCode & Swift Help
 * https://www.raywenderlich.com/98178/os-x-tutorial-menus-popovers-menu-bar-apps menubar tutorial
 * https://www.raywenderlich.com/128039/command-line-programs-macos-tutorial commandline tutorial (XCode 8)
 * https://developer.apple.com/macos/human-interface-guidelines/system-capabilities/search-and-spotlight/ for Spotlight and Search support. It would be nice to add Quicklook support for non-present files and Spotlight support for symlinked files (which are ignored by Spotlight)
 * start of a FinderSync extension for git https://github.com/uliwitness/LittleGit/blob/master/LittleGitFinderSyncExtension/GitFolderStatus.swift
 * example project using Finder Sync https://github.com/glegrain/GitStatus/tree/master/GitStatus
 * Currently UserDefaults is working fine for sharing data between the host app and the Finder Sync extension, but this might not scale for thousands of files, might need to switch to sqLite database, which can be stored in a common location then each target reads/writes to it (or Core Data)
  * https://www.raywenderlich.com/173972/getting-started-with-core-data-tutorial-2
  * https://www.raywenderlich.com/167743/sqlite-swift-tutorial-getting-started
  * http://www.atomicbird.com/blog/sharing-with-app-extensions
  * https://stackoverflow.com/questions/30156107/swift-share-sqlite-database-between-app-and-extension
  * http://dscoder.com/defaults.html
* TODO, more fine grain control of how often we query git-annex, see The Dispatch queue https://www.raywenderlich.com/148513/grand-central-dispatch-tutorial-swift-3-part-1
* See https://developer.apple.com/documentation/foundation/userdefaults section Persisting File References for advice on preserving permalink links to folders that work even across renames, probably better to do this, instead of using string paths :)
* https://stackoverflow.com/questions/2405305/how-to-tell-if-a-file-is-git-tracked-by-shell-exit-code maybe useful tricks for files that are in git, but not annex, also see https://git-scm.com/docs/git-ls-files for more details
 
Check if our Finder Sync extension is running:

    pluginkit -m | grep finder

Depending on which target is running, debug output might not show up in the XCode console. But if you launch the system Console app, it should be there.

Check for open files <https://www.cyberciti.biz/faq/howto-linux-get-list-of-open-files/>, first get process ID

    ps -aef | grep git-annex
    
Then list open files

    lsof -p <process-id> | less
