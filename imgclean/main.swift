//
//  main.swift
//  imgclean
//

import Foundation

func showHelp() {
    print("help message placeholder.")
}

let start = Date()

let fileManager = FileManager.default

let arguments = CommandLine.arguments
let basePath = CommandLine.argc >= 2 ? arguments[1] : fileManager.currentDirectoryPath


// get names of imagesets.
var names = Set<String>()
if let imagePaths = fileManager.enumerator(atPath: basePath) {
    for path in imagePaths {
        let path = path as! String
        if path.hasSuffix(".imageset") {
            names.insert(String(path.components(separatedBy: "/").last!.dropLast(".imageset".count)))
        }
    }
}

// get names of useful imagesets.
var useful = Set<String>()
if let sourcePaths = fileManager.enumerator(atPath: basePath) {
    for path in sourcePaths {
        let path = path as! String
        let fullPath = basePath + "/" + path
        if fileManager.isReadableFile(atPath: fullPath) {
            if let content = try? String(contentsOfFile: fullPath) {
                for name in names {
                    if content.contains("\"\(name)\"") {
                        useful.insert(name)
                    }
                }
            }
        }
    }
}

let result = names.subtracting(useful)
print("Found \(result.count) unused image asset(s):")
print(result.joined(separator: "\n"))

if arguments.count >= 3, arguments[2] == "-rm" {
    var toRemove = [String]()
    if let paths = fileManager.enumerator(atPath: basePath) {
        for path in paths {
            let path = path as! String
            for name in result {
                if path.components(separatedBy: "/").last! == "\(name).imageset" {
                    toRemove.append(path)
                }
            }
        }
    }
    for path in toRemove {
        if ((try? fileManager.removeItem(atPath: basePath + "/" + path)) != nil) {
            print("Successfully deleted \(path)")
        }
    }
}

let time = Date().timeIntervalSince(start)
print("\(time) secs used.")
