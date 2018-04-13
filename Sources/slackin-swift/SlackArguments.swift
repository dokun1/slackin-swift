//
//  SlackArguments.swift
//  slackin-swift
//
//  Created by David Okun IBM on 4/10/18.
//

import Foundation

enum SlackError: String, Error {
    case noToken = "No token has been specified"
    case invalidToken = "Token not valid"
}

class SlackArguments {
    static func extractToken(from arguments: [String]) -> String? {
        guard let last = arguments.last else {
            return nil
        }
        let components = last.split(separator: "-")
        if components.count < 5 {
            return nil
        }
        guard let first = components.first, String(first) == "xoxp" else {
            return nil
        }
        return last
    }
    
    // to make this work, follow these steps:
    // 1. create a file called "slackkey.txt" in your local documents directory
    // 2. make the only contents of the file the string of your key, and save it
    // this is a fail safe for running in xcode so you don't have to pass your token in
    static func debug_extractTokenFromFile() throws -> String {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("slackkey.txt")
            do {
                let token = try String(contentsOf: fileURL, encoding: .utf8).trimmingCharacters(in: .newlines)
                return token
            } catch {
                throw SlackError.noToken
            }
        } else {
            throw SlackError.noToken
        }
    }
}
