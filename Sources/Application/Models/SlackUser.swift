//
//  SlackUser.swift
//  Application
//
//  Created by David Okun IBM on 4/11/18.
//

import Foundation
import LoggerAPI

struct SlackUser: Codable {
    var name: String
    var presence: String
    
    static func getActiveCount(token: String) throws -> (Int, Int)? { // (activeUsers, totalUsers)
        Log.verbose("Requesting user info")
        let url = URL(string: "https://slack.com/api/users.list?token=\(token)")
        do {
            Log.verbose("Attempting to retrieve user information from url: \(String(describing: url))")
            let response = try Data(contentsOf: url!)
            Log.verbose("Attempting to decode user response")
            let slackResponse = try JSONDecoder().decode(SlackResponse.self, from: response)
            if let _ = slackResponse.error {
                Log.error("Error received from Slack API during user retrieval: \(String(describing: slackResponse.error))")
                throw SlackResponseError.channelNotFound
            } else {
                guard let users = slackResponse.members else {
                    Log.error("Could not retrieve user collection from slack response")
                    throw SlackResponseError.notAllowed
                }
                var activeCount = 0
                for user in users where user.presence == "active" {
                    activeCount = activeCount + 1
                }
                return (activeCount, users.count)
            }
        } catch let error {
            Log.error("Error retrieving users: \(error.localizedDescription)")
            throw error
        }
    }
}
