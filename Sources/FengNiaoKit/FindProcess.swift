//
//  FindProcess.swift
//  FengNiao
//
//  Created by LiuShulong on 25/03/2017.
//
//

import Foundation
import PathKit

struct FindProcess {
    let p : Process
    init?(path:Path,extensions:[String],exclude:[Path]){
        p = Process()
        p.launchPath = "/usr/bin/find"
        
        guard !extensions.isEmpty else {
            return nil
        }
        
        var args = [String]()
        args.append(path.string)
        
        for(i,ext) in extensions.enumerated() {
            if i == 0 {
                args.append("(")
            } else {
                args.append("-or")
            }
            
            args.append("-name")
            args.append("*.\(ext)")
            if i == extensions.count - 1 {
                args.append(")")
            }
            
        }
        
        print(exclude)
        
        for excludePath in exclude {
            
            let filePath = path + excludePath
            print(filePath)
            guard filePath.exists else { continue }

            
            args.append("-not")
            args.append("-path")
            
            if filePath.isDirectory {
                args.append("\(filePath.string)/*")
            } else {
                args.append(filePath.string)
            }
        }
        
        print(args)
        
        p.arguments = args
    }
    
    init?(path: String, extensions: [String], excluded: [String]) {
        self.init(path: Path(path), extensions: extensions, exclude: excluded.map { Path($0) })
    }

    
    func execute() -> Set<String> {
        let pipe = Pipe()
        p.standardOutput = pipe
        
        let fileHandler = pipe.fileHandleForReading
        p.launch()
        
        let data = fileHandler.readDataToEndOfFile()
        if let string = String(data:data, encoding: .utf8) {
            return Set(string.components(separatedBy: "\n").dropLast())
        } else {
            return []
        }
        
    }
    
}
