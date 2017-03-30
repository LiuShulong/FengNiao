//
//  FengNiaoKitSpec.swift
//  FengNiao
//
//  Created by LiuShulong on 24/03/2017.
//
//

import Foundation
import Spectre
import PathKit

@testable import FengNiaoKit

public func specFengNiaoKit(){
    describe("FengNiaokit") {
        
        let fixtures = Path(#file).parent().parent() + "Fixtures/"
        
        $0.before {
            
        }
        
        $0.after {
            
        }
        
        $0.describe("String Extension") {
            $0.it("should return plain name") {
                
                let s1 = "image@2x.tmp"
                let s2 = "/user/local/bin/find"
                let s3 = "image@3X.png"
                let s4 = "local.host"
                let s5 = "local.host.png"
                
                let exts = ["png"]
                
                try expect(s1.plainName(extensions: exts)) == "image@2x.tmp"
                try expect(s2.plainName(extensions: exts)) == "find"
                try expect(s3.plainName(extensions: exts)) == "image"
                try expect(s4.plainName(extensions: exts)) == "local.host"
                try expect(s5.plainName(extensions: exts)) == "local.host"

           
            }
            
            $0.it("patter string") {
                
                let s1 = "suffix_01"
                let s1used = "suffix_%d"
                let res = s1used.similarPatternWithNumber(other: s1)
                try expect(res).to.beTrue()
                
            }
            
        
        }
        
        $0.describe("String Searchers") {
            $0.it("Swift Searcher works", closure: { 
                let s1 = "UIImage(named: \"my_image\")"
                let s2 = "fdsfdsfds \"dd\" \"_fdfd\""
                let s3 = "let name = \"close_button@2x\"/n let image = UIImage(named: name)"
                let s4 = "test string: \"local.png\""
                let s5 = "test string: \"local.host\""
                
                let extensions = ["png"]
                let searcher = SwiftSearcher(extensions: extensions)
                let result = [s1,s2,s3,s4,s5].map({ searcher.search(in: $0) })
                
                try expect(result[0]) == Set(["my_image"])
                try expect(result[1]) == Set(["dd","_fdfd"])
                try expect(result[2]) == Set(["close_button"])
                try expect(result[3]) == Set(["local"])
                try expect(result[4]) == Set(["local.host"])
                
            })
        }
        
        $0.describe("Fengniaokitfunc", closure: {
            $0.it("find strings in swift", closure: {
                let path = fixtures + "FileStringSearcher"
                let fengNiao = FengNiao(projectPath:path.string,excludePaths:[],resourceExtensions:["png","jpg"],fileExtensions:["swift"])
                let result = fengNiao.allStringInUse()
                let expected: Set<String> = ["common.login","common.logout","live_btn_connect","name-key","无法支持"]
                try expect(result) == expected
            })
            
            $0.it("can find all resources in project") {
                let path = fixtures + "FindProcess"
                let fengniao = FengNiao(projectPath: path.string, excludePaths: ["Folder1/Ignore"], resourceExtensions: ["png","jpg","imageset"], fileExtensions: [])
                let result = fengniao.allResourceFiles()
                let expected = [
                    "file1":(fixtures + "FindProcess/file1.png").string,
                    "file2":(fixtures + "FindProcess/Folder1/file2.png").string,
                    "file3":(fixtures + "FindProcess/Folder1/SubFolder/file3.jpg").string,
                    "file4":(fixtures + "FindProcess/Folder2/file4.jpg").string,
                    "ignore_file":(fixtures + "FindProcess/Folder2/ignore_file.jpg").string
                ]
                
                try expect(result) == expected
                
            }
            
            $0.it("should filter similar pattern") {
                
                let all = [
                    "suffix_1" : "suffix_1.jpg",
                    "1_prefix" : "1_prefix.jpg",
                    "aa1_prefix" : "aa1_prefix.jpg"
                ]
                
                let used : Set<String> = [
                    "suffix_(\\d)", "aa(\\d)_prefix"
                ]
                let result = FengNiao.filterUnused(from: all, used: used)
                let expected:Set<String> = [
                    
                ]
            }
            
        })
        
        $0.describe("Find process") {
            
            $0.it("should find correct files") {
                let path = fixtures + "FindProcess/Folder1"
                let process = FindProcess(path: path, extensions: ["png","jpg","imageset"], exclude: ["Ignore"])
                let result = process?.execute() ?? []
                let expected: Set<String> = [
                    (path + "SubFolder/file3.jpg").string,
                    (path + "file2.png").string,
                ]
                try expect(result) == expected
            }
            
        }
        
    }
}
