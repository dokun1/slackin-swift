import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import Application

var token: String?

if let argumentToken = SlackArguments.extractToken(from: CommandLine.arguments) {
    token = argumentToken
} else {
    do {
        let debugToken = try SlackArguments.debug_extractTokenFromFile()
        token = debugToken
    } catch let error {
        Log.error(error.localizedDescription)
        exit(0)
    }
}

do {
    HeliumLogger.use(LoggerMessageType.verbose)
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
