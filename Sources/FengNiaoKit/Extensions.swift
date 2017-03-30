//
//  Extensions.swift
//  FengNiao
//
//  Created by LiuShulong on 22/03/2017.
//
//

import Foundation
import PathKit

let digitalRegrex = try! NSRegularExpression(pattern: "(\\d+)", options: .caseInsensitive)

extension String {
    var fullRange: NSRange {
        return NSMakeRange(0, utf16.count)
    }
    
    func plainName(extensions:[String]) -> String {
        let p = Path(self.lowercased())
        var result:String
        if let ext = p.extension,extensions.contains(ext){
            result = p.lastComponentWithoutExtension
        } else {
            result = p.lastComponent
        }
        var r = result
        if r.hasSuffix("@2x") || r.hasSuffix("@3x") {
            r = String(describing: r.utf16.dropLast(3))
        }
        return r
    }
    
    
    func similarPatternWithNumber(other: String) -> Bool {
        // self = > pattern "image%02d"
        // other
        let matches = digitalRegrex.matches(in: other, options: [], range: other.fullRange)
        guard matches.count >= 1 else { return false }
        
        let lastMatch = matches.last!
        let digitalRange = lastMatch.rangeAt(1)
        
        var prefix: String?
        var suffix: String?
        
        let digitalLocation = digitalRange.location
        if digitalLocation != 0 {
            let index = other.index(other.startIndex, offsetBy: digitalLocation)
            prefix = other.substring(to: index)
            
            
        }
        
        let digitalMaxRange = NSMaxRange(digitalRange)
        if digitalMaxRange < other.utf16.count {
            let index = other.index(other.startIndex, offsetBy: digitalMaxRange)
            suffix = other.substring(from: index)
        }
        
        switch (prefix,suffix) {
        case (nil,nil):
            return false
        case (let p?,let s?): return hasPrefix(p) && hasSuffix(s)
        case (let p?,nil): return hasPrefix(p)
        case (nil,let s?): return hasPrefix(s)
        }
        
    }

    
}
