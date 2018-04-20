import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import Application

var token: String?

HeliumLogger.use(LoggerMessageType.verbose)

if let argumentToken = SlackArguments.extractToken(from: CommandLine.arguments) {
    Log.verbose("Token found and validated: \(argumentToken)")
    token = argumentToken
} else {
    do {
        let debugToken = try SlackArguments.debug_extractTokenFromFile()
        Log.verbose("Debug token found and validated: \(debugToken)")
        token = debugToken
    } catch let error {
        Log.error("Could not start application without token: \(error.localizedDescription)")
        exit(0)
    }
}

do {
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
