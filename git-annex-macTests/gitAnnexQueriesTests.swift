//
//  gitAnnexQueriesTests.swift
//  git-annex-turtleTests
//
//  Created by Andrew Ringler on 2/6/18.
//  Copyright © 2018 Andrew Ringler. All rights reserved.
//

import XCTest

class gitAnnexQueriesTests: XCTestCase {
    var watchedFolder: WatchedFolder?
    
    override func setUp() {
        super.setUp()

        // Create git annex repo in TMP dir
        do {
            let directoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)!
            let path = PathUtils.path(for: directoryURL)!
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            XCTAssertTrue(GitAnnexQueries.createRepo(at: path), "could not initialize repository at \(path)")
            if let uuid = GitAnnexQueries.gitGitAnnexUUID(in: path) {
                watchedFolder = WatchedFolder(uuid: uuid, pathString: path)
            } else {
                XCTFail("could not retrieve UUID for folder \(path)")
            }
        } catch {
            XCTFail("unable to create a new git annex repo in temp folder \(error)")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        
        // Remove tmp dir
        if let path = watchedFolder?.pathString {
            let directory = PathUtils.urlFor(absolutePath: path)
            do {
                try FileManager.default.removeItem(at: directory)
            } catch {
                NSLog("Unable to cleanup folder after tests \(path)")
            }
        }
    }

    func testChildren() {
        let file1Path = "a.txt"
        let file1 = PathUtils.url(for: file1Path, in: watchedFolder!)
        do {
            try "some text".write(to: file1, atomically: false, encoding: .utf8)
        }
        catch {
            XCTFail("unable to create file in repo")
        }
        
        let gitAddResult = GitAnnexQueries.gitAnnexCommand(for: file1Path, in: watchedFolder!.pathString, cmd: CommandString.add)
        if !gitAddResult.success { XCTFail("unable to add file \(gitAddResult.error)")}
        
        let children = GitAnnexQueries.immediateChildrenNotIgnored(relativePath: PathUtils.CURRENT_DIR, in: watchedFolder!)
        XCTAssertEqual(Set(children), Set([file1Path]))
    }
}