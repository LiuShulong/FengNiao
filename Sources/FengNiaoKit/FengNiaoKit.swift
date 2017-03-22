import Foundation
import PathKit

public struct Foo{
    
    public init() {
        
    }
    
	public func bar(){
		print("hello")
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
    
    func stringInUse() -> [String] {
        
        
        
        return []
    }
    
    func resourcesInUse() -> [String: String] {
        fatalError()
    }
    
    public func delete() -> () {
        fatalError()
    }
    
}
