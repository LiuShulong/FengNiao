import Foundation
import PathKit

public struct Foo{
    
    public init() {
        
    }
    
	public func bar(){
		print("hello")
	}
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
    
    public func unusedResources() -> [String] {
        fatalError()
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
    
    func resourcesInUse() -> [String: String] {
        fatalError()
    }
    
    public func delete() -> () {
        fatalError()
    }
    
}
