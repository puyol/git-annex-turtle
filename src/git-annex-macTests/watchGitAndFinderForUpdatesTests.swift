//
//  watchGitAndFinderForUpdatesTests.swift
//  git-annex-turtleTests
//
//  Created by Andrew Ringler on 3/14/18.
//  Copyright © 2018 Andrew Ringler. All rights reserved.
//

import XCTest

class watchGitAndFinderForUpdatesTests: XCTestCase {
    var fullScan: FullScan?
    var testDir: String?
    var repo1: WatchedFolder?
    var repo2: WatchedFolder?
    var queries: Queries?
    var gitAnnexQueries: GitAnnexQueries?
    var watchGitAndFinderForUpdates: WatchGitAndFinderForUpdates?
    
    override func setUp() {
        super.setUp()
        
        TurtleLog.setLoggingLevel(.debug)
        
        testDir = TestingUtil.createTmpDir()
        TurtleLog.info("Using testing dir: \(testDir!)")
        let config = Config(dataPath: "\(testDir!)/turtle-monitor")
        let storeURL = PathUtils.urlFor(absolutePath: "\(testDir!)/testingDatabase")
        
        let persistentContainer = TestingUtil.persistentContainer(mom: managedObjectModel, storeURL: storeURL)
        let data = DataEntrypoint(persistentContainer: persistentContainer)
        queries = Queries(data: data)
        gitAnnexQueries = GitAnnexQueries(gitAnnexCmd: config.gitAnnexBin()!, gitCmd: config.gitBin()!)
        fullScan = FullScan(gitAnnexQueries: gitAnnexQueries!, queries: queries!)
        let handleStatusRequests = HandleStatusRequests(queries: queries!, gitAnnexQueries: gitAnnexQueries!)

        watchGitAndFinderForUpdates = WatchGitAndFinderForUpdates(gitAnnexTurtle: GitAnnexTurtleStub(), data: data, fullScan: fullScan!, handleStatusRequests: handleStatusRequests, gitAnnexQueries: gitAnnexQueries!)
        
        repo1 = TestingUtil.createInitGitAnnexRepo(at: "\(testDir!)/repo1", gitAnnexQueries: gitAnnexQueries!)
        repo2 = TestingUtil.createInitGitAnnexRepo(at: "\(testDir!)/repo2", gitAnnexQueries: gitAnnexQueries!)
    }
    
    override func tearDown() {
        TestingUtil.removeDir(testDir)
        
        super.tearDown()
    }
    
    func testWatchGitAndFinderForUpdates() {
        //
        // Repo 1
        //
        // set num copies to 2, so all files will be lacking
        XCTAssertTrue(gitAnnexQueries!.gitAnnexSetNumCopies(numCopies: 2, in: repo1!).success)
        let file1 = "a name with spaces.txt"
        TestingUtil.gitAnnexCreateAndAdd(content: "file1 content", to: file1, in: repo1!, gitAnnexQueries: gitAnnexQueries!)
        
        let file2 = "b ∆∆ söme unicode too.txt"
        TestingUtil.gitAnnexCreateAndAdd(content: "file2 content", to: file2, in: repo1!, gitAnnexQueries: gitAnnexQueries!)
        
        let file3 = "subdirA/c.txt"
        TestingUtil.createDir(dir: "subdirA", in: repo1!)
        TestingUtil.gitAnnexCreateAndAdd(content: "file3 content", to: file3, in: repo1!, gitAnnexQueries: gitAnnexQueries!)
        
        let file4 = "subdirA/dirC/d.txt"
        TestingUtil.createDir(dir: "subdirA/dirC", in: repo1!)
        TestingUtil.gitAnnexCreateAndAdd(content: "file4 content", to: file4, in: repo1!, gitAnnexQueries: gitAnnexQueries!)
        
        let file5 = "subdirA/e.txt"
        TestingUtil.gitAnnexCreateAndAdd(content: "file5 content", to: file5, in: repo1!, gitAnnexQueries: gitAnnexQueries!)
        
        //
        // Repo 2
        //
        let file6 = "a.txt"
        TestingUtil.gitAnnexCreateAndAdd(content: "file6 content", to: file6, in: repo2!, gitAnnexQueries: gitAnnexQueries!)
        let file7 = "b.txt"
        TestingUtil.gitAnnexCreateAndAdd(content: "file7 content", to: file7, in: repo2!, gitAnnexQueries: gitAnnexQueries!)
        
        TestingUtil.createDir(dir: "anEmptyDir", in: repo2!)
        
        TestingUtil.createDir(dir: "anEmptyDirWithEmptyDirs", in: repo2!)
        TestingUtil.createDir(dir: "anEmptyDirWithEmptyDirs/a", in: repo2!)
        TestingUtil.createDir(dir: "anEmptyDirWithEmptyDirs/b", in: repo2!)
        
//        watchGitAndFinderForUpdates.
        
        
        // Start a full scan on both repos
//        fullScan!.startFullScan(watchedFolder: repo1!)
//        fullScan!.startFullScan(watchedFolder: repo2!)
        
        let done = NSPredicate(format: "doneScanning == true")
        expectation(for: done, evaluatedWith: self, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
        
        // Repo 1
        if let status1 = queries!.statusForPathV2Blocking(path: file1, in: repo1!) {
            XCTAssertEqual(status1.presentStatus, Present.present)
            XCTAssertEqual(status1.enoughCopies, EnoughCopies.lacking)
            XCTAssertEqual(status1.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve status for \(file1)")
        }
        if let status2 = queries!.statusForPathV2Blocking(path: file2, in: repo1!) {
            XCTAssertEqual(status2.presentStatus, Present.present)
            XCTAssertEqual(status2.enoughCopies, EnoughCopies.lacking)
            XCTAssertEqual(status2.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve status for \(file2)")
        }
        if let status3 = queries!.statusForPathV2Blocking(path: file3, in: repo1!) {
            XCTAssertEqual(status3.presentStatus, Present.present)
            XCTAssertEqual(status3.enoughCopies, EnoughCopies.lacking)
            XCTAssertEqual(status3.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve status for \(file3)")
        }
        
        if let statusSubdirA = queries!.statusForPathV2Blocking(path: "subdirA", in: repo1!) {
            XCTAssertEqual(statusSubdirA.presentStatus, Present.present)
            XCTAssertEqual(statusSubdirA.isDir, true)
            XCTAssertEqual(statusSubdirA.enoughCopies, EnoughCopies.lacking)
            XCTAssertEqual(statusSubdirA.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve folder status for 'subdirA'")
        }
        
        if let status4 = queries!.statusForPathV2Blocking(path: file4, in: repo1!) {
            XCTAssertEqual(status4.presentStatus, Present.present)
            XCTAssertEqual(status4.enoughCopies, EnoughCopies.lacking)
            XCTAssertEqual(status4.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve status for \(file4)")
        }
        if let status5 = queries!.statusForPathV2Blocking(path: file5, in: repo1!) {
            XCTAssertEqual(status5.presentStatus, Present.present)
            XCTAssertEqual(status5.enoughCopies, EnoughCopies.lacking)
            XCTAssertEqual(status5.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve status for \(file5)")
        }
        
        if let statusSubdirC = queries!.statusForPathV2Blocking(path: "subdirA/dirC", in: repo1!) {
            XCTAssertEqual(statusSubdirC.presentStatus, Present.present)
            XCTAssertEqual(statusSubdirC.isDir, true)
            XCTAssertEqual(statusSubdirC.enoughCopies, EnoughCopies.lacking)
            XCTAssertEqual(statusSubdirC.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve folder status for 'subdirA/dirC'")
        }
        
        
        
        if let wholeRepo = queries!.statusForPathV2Blocking(path: PathUtils.CURRENT_DIR, in: repo1!) {
            XCTAssertEqual(wholeRepo.presentStatus, Present.present)
            XCTAssertEqual(wholeRepo.isDir, true)
            XCTAssertEqual(wholeRepo.enoughCopies, EnoughCopies.lacking)
            XCTAssertEqual(wholeRepo.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve folder status for whole repo1")
        }
        
        
        // Repo 2
        if let status6 = queries!.statusForPathV2Blocking(path: file6, in: repo2!) {
            XCTAssertEqual(status6.presentStatus, Present.present)
            XCTAssertEqual(status6.enoughCopies, EnoughCopies.enough)
            XCTAssertEqual(status6.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve status for \(file6)")
        }
        if let status7 = queries!.statusForPathV2Blocking(path: file7, in: repo2!) {
            XCTAssertEqual(status7.presentStatus, Present.present)
            XCTAssertEqual(status7.enoughCopies, EnoughCopies.enough)
            XCTAssertEqual(status7.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve status for \(file7)")
        }
        // An empty directory is always good :)
        if let dir = queries!.statusForPathV2Blocking(path: "anEmptyDir", in: repo2!) {
            XCTAssertEqual(dir.presentStatus, Present.present)
            XCTAssertEqual(dir.isDir, true)
            XCTAssertEqual(dir.enoughCopies, EnoughCopies.enough)
        } else {
            XCTFail("could not retrieve folder status for 'anEmptyDir'")
        }
        
        // An empty directory with empty directories inside it
        if let dir = queries!.statusForPathV2Blocking(path: "anEmptyDirWithEmptyDirs/a", in: repo2!) {
            XCTAssertEqual(dir.presentStatus, Present.present)
            XCTAssertEqual(dir.isDir, true)
            XCTAssertEqual(dir.enoughCopies, EnoughCopies.enough)
        } else {
            XCTFail("could not retrieve folder status for 'anEmptyDirWithEmptyDirs/a'")
        }
        if let dir = queries!.statusForPathV2Blocking(path: "anEmptyDirWithEmptyDirs/b", in: repo2!) {
            XCTAssertEqual(dir.presentStatus, Present.present)
            XCTAssertEqual(dir.isDir, true)
            XCTAssertEqual(dir.enoughCopies, EnoughCopies.enough)
        } else {
            XCTFail("could not retrieve folder status for 'anEmptyDirWithEmptyDirs/b'")
        }
        if let dir = queries!.statusForPathV2Blocking(path: "anEmptyDirWithEmptyDirs", in: repo2!) {
            XCTAssertEqual(dir.presentStatus, Present.present)
            XCTAssertEqual(dir.isDir, true)
            XCTAssertEqual(dir.enoughCopies, EnoughCopies.enough)
        } else {
            XCTFail("could not retrieve folder status for 'anEmptyDirWithEmptyDirs'")
        }
        
        if let wholeRepo = queries!.statusForPathV2Blocking(path: PathUtils.CURRENT_DIR, in: repo2!) {
            XCTAssertEqual(wholeRepo.presentStatus, Present.present)
            XCTAssertEqual(wholeRepo.isDir, true)
            XCTAssertEqual(wholeRepo.enoughCopies, EnoughCopies.enough)
            XCTAssertEqual(wholeRepo.numberOfCopies, 1)
        } else {
            XCTFail("could not retrieve folder status for whole repo2")
        }
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    func doneScanning() -> Bool {
        return fullScan!.isScanning(watchedFolder: repo1!) == false
            && fullScan!.isScanning(watchedFolder: repo2!) == false
    }
}

// https://stackoverflow.com/a/30593673/8671834
extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// https://stackoverflow.com/a/42222302/8671834
extension XCTestCase {
    
    func wait(for duration: TimeInterval) {
        let waitExpectation = expectation(description: "Waiting")
        
        let when = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: when) {
            waitExpectation.fulfill()
        }
        
        // We use a buffer here to avoid flakiness with Timer on CI
        waitForExpectations(timeout: duration + 0.5)
    }
}