import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import Application

enum SlackError: String, Error {
    case noToken = "No token has been specified"
    case invalidToken = "Token not valid"
}

var token: String?

let arguments = ProcessInfo().arguments
print(arguments)

//if let tokenArgument = 

if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
    let fileURL = dir.appendingPathComponent("slackkey.txt")
    do {
        token = try String(contentsOf: fileURL, encoding: .utf8).trimmingCharacters(in: .newlines)
    } catch let error {
        print(error.localizedDescription)
    }
}

do {
    HeliumLogger.use(LoggerMessageType.info)
    let app = try App()
    guard let unwrappedToken = token else {
        throw SlackError.noToken
    }
    try app.run(token: unwrappedToken)
} catch SlackError.noToken {
    Log.error(SlackError.noToken.rawValue)
} catch let error {
    Log.error(error.localizedDescription)
}
