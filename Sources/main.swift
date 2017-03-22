import Foundation
import CommandLineKit
import Rainbow

let cli = CommandLineKit.CommandLine()

let projectOption = StringOption(shortFlag: "p",
                                 longFlag: "project",
                                 helpMessage: "Path to the output project")
let resourceExtensionsOptions = MultiStringOption(shortFlag: "r",
                                    longFlag: "resource-extensions",
                                    helpMessage: "extension to search.")

let excludePathsOptions = MultiStringOption(shortFlag: "e", longFlag: "excludePath",
                                            helpMessage: "file extensions to search.")

let fileExtensionOptions = MultiStringOption(shortFlag: "f", longFlag: "file-extensions",
                      helpMessage: "file extensions to search.")

let help = BoolOption(shortFlag: "h", longFlag: "help",
                      helpMessage: "Prints a help message.")



cli.addOptions(projectOption, resourceExtensionsOptions, fileExtensionOptions, excludePathsOptions,help)

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .error:
        str = s.red.bold
    case .optionFlag:
        str = s.green.underline
    case .optionHelp:
        str = s.lightBlue
    default:
        str = s
    }
    
    return cli.defaultFormat(s:str, type: type)
}



do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}


let project = projectOption.value ?? "."
let resourceExtensions = resourceExtensionsOptions.value ?? ["png","jpg","imageset"]
let fileExtensions = fileExtensionOptions.value ?? ["storyboard","xib","swift","m","mm"]


print("File path is \(projectOption.value!)")
print("Compress is \(resourceExtensionsOptions.value)")
print("Verbosity is \(fileExtensionOptions.value)")
