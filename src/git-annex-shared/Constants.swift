//
//  Constants.swift
//  git-annex-turtle
//
//  Created by Andrew Ringler on 1/11/18.
//  Copyright © 2018 Andrew Ringler. All rights reserved.
//

import Foundation

let groupID = "group.com.andrewringler.git-annex-mac.sharedgroup"
let databaseName = "git_annex_turtle_data_v1.sqlite"

//let GitAnnexTurtleDbPrefix = "gitannex."
//let GitAnnexTurtleUserDefaultsWatchedFoldersUpdated = "gitannex.watched-folders-updated"
//let GitAnnexTurtleWatchedFoldersDbPrefix = "gitannex.watched-folders"
//func GitAnnexTurtleRequestBadgeDbPrefixNoPath(in watchedFolder: WatchedFolder) -> String {
//    return "gitannex.requestbadge." + watchedFolder.uuid.uuidString + "."
//}
//func GitAnnexTurtleRequestBadgeDbPrefix(for path: String, in watchedFolder: WatchedFolder) -> String {
//    return "gitannex.requestbadge." + watchedFolder.uuid.uuidString + "." + path
//}
//func GitAnnexTurtleStatusUpdatedDbPrefix(for path: String, in watchedFolder: WatchedFolder) -> String {
//    return "gitannex.statusupdated." + watchedFolder.uuid.uuidString + "." + path
//}
//func GitAnnexTurtleStatusUpdatedDbPrefixNoPath(in watchedFolder: WatchedFolder) -> String {
//    return "gitannex.statusupdated." + watchedFolder.uuid.uuidString + "."
//}
//func GitAnnexTurtleStatusDbPrefix(for path: String, in watchedFolder: WatchedFolder) -> String {
//    return "gitannex.statussaved." + watchedFolder.uuid.uuidString + "." + path
//}
//func GitAnnexTurtleStatusDbPrefixNoPath(in watchedFolder: WatchedFolder) -> String {
//    return "gitannex.statussaved." + watchedFolder.uuid.uuidString + "."
//}
//func GitAnnexTurtleBeginObserving(in watchedFolder: WatchedFolder, observed path: String) -> String {
//    return "gitannex.beginobserving." + watchedFolder.uuid.uuidString + "." + path
//}
//func GitAnnexTurtleBeginObservingNoPath(in watchedFolder: WatchedFolder) -> String {
//    return "gitannex.beginobserving." + watchedFolder.uuid.uuidString + "."
//}

//protocol Command {
//    var cmdString :String { get }
//    func dbPrefixWithUUID(for path: String, in watchedFolder: WatchedFolder) -> String
//    func dbPrefixWithUUID(in watchedFolder: WatchedFolder) -> String
//}
//class GitAnnexCommand: Equatable, Hashable, Command {
//    let cmdString :String
//    private let dbPrefix :String
//
//    init(cmdString :String, dbPrefix :String) {
//        self.cmdString = cmdString
//        self.dbPrefix = dbPrefix
//    }
//
//    static func ==(lhs: GitAnnexCommand, rhs: GitAnnexCommand) -> Bool {
//        return lhs.cmdString == rhs.cmdString
//    }
//    var hashValue: Int {
//        return cmdString.hashValue
//    }
//
//    func dbPrefixWithUUID(in watchedFolder: WatchedFolder) -> String {
//        return dbPrefix + watchedFolder.uuid.uuidString + "."
//    }
//    func dbPrefixWithUUID(for path: String, in watchedFolder: WatchedFolder) -> String {
//        return dbPrefix + watchedFolder.uuid.uuidString + "." + path
//    }
//}
//struct GitAnnexCommands {
//    static let Get = GitAnnexCommand(cmdString: "get", dbPrefix: "gitannex.command.git-annex-get.")
//    static let Add = GitAnnexCommand(cmdString: "add", dbPrefix: "gitannex.command.git-annex-add.")
//    static let Drop = GitAnnexCommand(cmdString: "drop", dbPrefix: "gitannex.command.git-annex-drop.")
//    static let Unlock = GitAnnexCommand(cmdString: "unlock", dbPrefix: "gitannex.command.git-annex-unlock.")
//    static let Lock = GitAnnexCommand(cmdString: "lock", dbPrefix: "gitannex.command.git-annex-lock.")
//
//    static let all = [Get, Add, Drop, Unlock, Lock]
//}
//class GitCommand: Equatable, Hashable, Command {
//    let cmdString :String
//    private let dbPrefix :String
//
//    init(cmdString :String, dbPrefix :String) {
//        self.cmdString = cmdString
//        self.dbPrefix = dbPrefix
//    }
//    static func ==(lhs: GitCommand, rhs: GitCommand) -> Bool {
//        return lhs.cmdString == rhs.cmdString
//    }
//    var hashValue: Int {
//        return cmdString.hashValue
//    }
//}
struct GitConfig {
    let name :String
}
struct GitConfigs {
    static let AnnexUUID = GitConfig(name: "annex.uuid")
}

let UNKNOWN_COPIES: Double = -1.0
enum Present: String {
    case present = "present"
    case absent = "absent"
    case partialPresent = "partialPresent"
    
    public func menuDisplay() -> String {
        switch self {
        case .present: return "Present"
        case .absent: return "Absent"
        case .partialPresent: return "Partially Present"
        }
    }
    
    static func &&(lhs: Present, rhs: Present) -> Present {
        switch lhs {
        case .partialPresent:
            return .partialPresent
        case .present:
            switch rhs {
            case .present:
                return .present
            case .absent, .partialPresent:
                return .partialPresent
            }
        case .absent:
            switch rhs {
            case .absent:
                return .absent
            case .present, .partialPresent:
                return .partialPresent
            }
        }
    }
    
    public func isPresent() -> Bool {
        return self == .present
    }
}
enum EnoughCopies: String {
    case enough = "enough"
    case lacking = "lacking"
    
    public func menuDisplay() -> String {
        switch self {
        case .enough: return "have enough"
        case .lacking: return "want more"
        }
    }
    
    static func &&(lhs: EnoughCopies, rhs: EnoughCopies) -> EnoughCopies {
        switch lhs {
        case .enough:
            return rhs
        case .lacking:
            return .lacking
        }
    }
    
    public func isEnough() -> Bool {
        return self == .enough
    }
}

enum GitAnnexJSON: String {
    case success = "success"
    case present = "present"
    case directory = "directory"
    case file = "file"
    case localAnnexKeys = "local annex keys"
    case annexedFilesInWorkingTree = "annexed files in working tree"
    case command = "command"
    case note = "note"
    case whereis = "whereis"
    case key = "key"
    case here = "here"
}

class PathUtils {
    public static let CURRENT_DIR = "."
    
    // https://gist.github.com/jweinst1/319e0cd35213e8eff0ab
    //counts a specific letter in a string
    class func count(_ char:Character, in str:String) -> Int {
        let letters = Array(str); var count = 0
        for letter in letters {
            if letter == char {
                count += 1
            }
        }
        return count
    }

    class func sortedDeepestDirFirst(_ paths: [String]) -> [String] {
        return paths.sorted {
            if $0 == PathUtils.CURRENT_DIR {
                return false
            }
            if $1 == PathUtils.CURRENT_DIR {
                return true
            }
            return count("/", in: $0) > count("/", in: $1) }
    }
    
    class func isCurrent(_ path: String) -> Bool {
        return path == CURRENT_DIR
    }
    
    class func path(for url: URL) -> String? {
        return (url as NSURL).path
    }
    
    class func urlFor(absolutePath: String) -> URL {
        return URL(fileURLWithPath: absolutePath)
    }
    
    class func absolutePath(for relativePath: String, in watchedFolder: WatchedFolder) -> String {
        if isCurrent(relativePath) {
            return watchedFolder.pathString
        }
        return "\(watchedFolder.pathString)/\(relativePath)"
    }
    
    class func relativePath(for url: URL, in watchedFolder: WatchedFolder) -> String? {
        if let path = path(for: url) {
            return relativePath(for: path, in: watchedFolder)
        }
        return nil
    }
    
    class func createTmpDir() -> String? {
        do {
            let directoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)!
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            if let path = PathUtils.path(for: directoryURL) {
                return path
            }
        } catch {
            TurtleLog.error("unable to create a new temp folder \(error)")
            return nil
        }
        TurtleLog.error("unable to create a new temp folder")
        return nil
    }
    
    class func removeDir(_ absolutePath: String?) {
        if let path = absolutePath {
            let directory = PathUtils.urlFor(absolutePath: path)
            do {
                try FileManager.default.removeItem(at: directory)
            } catch {
                TurtleLog.error("Unable to cleanup folder \(path)")
            }
        }
    }
    
    class func relativePath(for absolutePath: String, in watchedFolder: WatchedFolder) -> String? {
        // Root?
        if absolutePath == watchedFolder.pathString {
            return CURRENT_DIR
        }
        
        // Sub-folder or file?
        let prefix = "\(watchedFolder.pathString)/"
        if absolutePath.starts(with: prefix) {
            var relativePath = absolutePath
            relativePath.removeFirst(prefix.count)
            return relativePath
        }
        return nil
    }
    
    // instantiating URL directly doesn't work, it prepends the container path
    // see https://stackoverflow.com/questions/27062454/converting-url-to-string-and-
    class func url(for relativePath: String, in watchedFolder: WatchedFolder) -> URL {
        return URL(fileURLWithPath: absolutePath(for: relativePath, in: watchedFolder))
    }
    
    // parent is this path, minus one component
    class func parent(for relativePath: String, in watchedFolder: WatchedFolder) -> String? {
        if isCurrent(relativePath) {
            return nil // no parent, we are at the root
        }
        let absolutePath = PathUtils.absolutePath(for: relativePath, in: watchedFolder)
        var url = PathUtils.urlFor(absolutePath: absolutePath)
        url.deleteLastPathComponent()
        return PathUtils.relativePath(for: url, in: watchedFolder)
    }
    
    class func children(in watchedFolder: WatchedFolder) -> (files: [String], dirs: [String]) {
        return children(path: CURRENT_DIR, in: watchedFolder)
    }
    
    class func children(path subdirectoryRelativePath: String, in watchedFolder: WatchedFolder) -> (files: [String], dirs: [String]) {
        var files: [String] = []
        var dirs: [String] = []
        let rootPath = PathUtils.absolutePath(for: subdirectoryRelativePath, in: watchedFolder)
        
        do {
            for path in try FileManager.default.subpathsOfDirectory(atPath: rootPath) {
                if path != ".git" && !path.starts(with: ".git/") /* ignore root level git directory */ {
                    if PathUtils.directoryExistsAt(relativePath: path, in: watchedFolder) {
                        dirs.append(path)
                    } else {
                        files.append(path)
                    }
                }
            }
            dirs.append(CURRENT_DIR)
        } catch {
            TurtleLog.error("Unable to enumerate files in \(watchedFolder)")
        }
        
        return (files: files, dirs: dirs)
    }
    
    // https://gist.github.com/brennanMKE/a0a2ee6aa5a2e2e66297c580c4df0d66
    private class func directoryExistsAt(absolutePath: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: absolutePath, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    class func directoryExistsAt(relativePath: String, in watchedFolder: WatchedFolder) -> Bool {
        let absolutePath = self.absolutePath(for: relativePath, in: watchedFolder)
        return PathUtils.directoryExistsAt(absolutePath: absolutePath)
    }
}

enum CommandType: String {
    case git
    case gitAnnex
    
    public var isGitAnnex: Bool { return self == .gitAnnex }
    public var isGit: Bool { return self == .git }
}
enum CommandString: String {
    case get = "get"
    case add = "add"
    case drop = "drop"
    case unlock = "unlock"
    case lock = "lock"
    case initCmd = "init"
    case numCopies = "numcopies"
}

