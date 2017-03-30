import Foundation
import PathKit
import Rainbow

enum FengNiaoKitError:Error {
    case noResourceExtension
    case noFileExtension
}
enum FileType {
    case swift
    case objc
    case xib
    
    init?(ext:String) {
        switch ext.lowercased() {
        case "swift":self = .swift
        case "mm":self = .objc
        case "xib","storyboard":self = .xib
        default:return nil
        }
    }
    
    func searcher(extensions:[String]) -> StringSearcher {
        switch self {
        case .swift:
            return SwiftSearcher(extensions:extensions)
        case .objc:
            return ObjCSearcher(extensions:extensions)
        case .xib:
            return XibSearcher(extensions:extensions)
        }
    }
    
}

public struct FileInfo {
    let path: String
}

public struct FengNiao {
    let projectPath: Path
    let excludePaths:[Path]
    let resourceExtensions:[String]
    let fileExtensions:[String]
    
    public init(projectPath: String, excludePaths : [String], resourceExtensions: [String],fileExtensions: [String]) {
        let path = Path(projectPath).absolute()
        self.projectPath = path
        self.excludePaths = excludePaths.map{path + Path($0)}
        self.resourceExtensions = resourceExtensions
        self.fileExtensions = fileExtensions
        
    }
    
    public func unusedResources() throws -> [String] {
        guard !resourceExtensions.isEmpty else {
            throw FengNiaoKitError.noResourceExtension
        }
        
        guard !fileExtensions.isEmpty else {
            throw FengNiaoKitError.noFileExtension
        }
        
        let allResources = allResourceFiles()
        let allStrings = allStringInUse()
        return []
    }
    
    func allStringInUse() -> Set<String> {
        return stringsInUse(at: projectPath)
    }
    
    func stringsInUse(at path:Path) -> Set<String> {
        guard let subPaths = try? path.children() else {
            print("Path reading error.")
            return []
        }
        
        var result = [String]()
        for subPath in subPaths {
            if subPath.lastComponent.hasPrefix(".") {
                continue
            }
            if excludePaths.contains(subPath) {
                continue
            }
            if subPath.isDirectory {
                result.append(contentsOf: stringsInUse(at: subPath))
            } else {
                let fileExt = subPath.extension ?? ""
                guard fileExtensions.contains(fileExt) else {
                    continue
                }
                
                let searcher:StringSearcher
                if let fileType = FileType(ext:fileExt) {
                    searcher = fileType.searcher(extensions:fileExtensions)
                } else {
                    searcher = GeneralSearcher(extensions:fileExtensions)
                }
                
                let content = (try? subPath.read()) ?? ""
                result.append(contentsOf: searcher.search(in: content))
            }
            
        }
        return Set(result)
    }
    
    func allResourceFiles() -> [String: String] {
        guard let process = FindProcess(path: projectPath, extensions: resourceExtensions, exclude: excludePaths) else {
            return [:]
        }
        
        let found = process.execute()
        var files = [String:String]()
        
        let regularDirEetensions = ["imageset","launchimage","appiconset","bundle"]
        let nonDirExtensions = resourceExtensions.filter { !regularDirEetensions.contains($0) }
        
        fileLoop:  for file in found {
            let dirPath = regularDirEetensions.map{ ".\($0)/" }
            for dir in dirPath where file.contains(dir) {
                continue fileLoop
            }
            
            let filePath = Path(file)
            if let ext = filePath.extension, filePath.isDirectory && nonDirExtensions.contains(ext) {
                continue
            }
            
            let key = file.plainName(extensions: resourceExtensions)
            if let existing = files[key] {
                print("Found duplicated file key:\(key).Exsiting:\(existing)".yellow.bold)
                continue
            }
            
            files[key] = file
            
        }
    
        
        return files
    }
    
    static func filterUnused(from all:[String: String], used: Set<String>) -> Set<String> {
        let unusedPair = all.filter { key, _ in
            return !used.contains(key)
                && used.contains{ $0.similarPatternWithNumber(other: key) }
        }
        
        return Set(unusedPair.map{ $0.value })
    }
    
    public func delete() -> () {
        fatalError()
    }
    
}



