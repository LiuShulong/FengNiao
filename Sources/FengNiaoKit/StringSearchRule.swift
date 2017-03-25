//
//  StringSearchRule.swift
//  FengNiao
//
//  Created by LiuShulong on 22/03/2017.
//
//

import Foundation

protocol StringSearcher {
    func search(in content: String) -> Set<String>
}

protocol RegrexStringsSearcher: StringSearcher {
    var extensions: [String] { get }
    var patterns: [String]{ get }
}

extension RegrexStringsSearcher {
    func search(in content: String) -> Set<String> {
        var result = Set<String>()
        for pattern in patterns {
            guard let regrex = try? NSRegularExpression(pattern:pattern,options:[]) else {
                print("Failed to create expression:\(pattern)")
                continue
            }
            
            let matches = regrex.matches(in: content, options: [], range: content.fullRange)
            for checkingResult in matches {
                let range = checkingResult.rangeAt(1)
                let extracted = NSString(string: content).substring(with: range)
                result.insert(extracted.plainName(extensions: extensions))
            }
        }
        return result
    }
}

struct SwiftSearcher: RegrexStringsSearcher{
    var extensions: [String]
    let patterns = ["\"(.+?)\""]
}


struct ObjCSearcher: RegrexStringsSearcher {
    var extensions: [String]
    let patterns = ["@\"(.+?)\"","\"(.+?)\""]
}

struct XibSearcher:RegrexStringsSearcher {
    var extensions: [String]
    let patterns: [String] = ["image name=\"(.+?)\""]
    
}

struct GeneralSearcher: RegrexStringsSearcher {
    var extensions: [String]
    var patterns: [String] {
        if extensions.isEmpty {
            return []
        }
        
        let joined = extensions.joined(separator: "|")
        return["\"(.+?)\\.(\(joined))\""]
    }
    
}


