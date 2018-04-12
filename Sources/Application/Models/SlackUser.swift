//
//  SlackUser.swift
//  Application
//
//  Created by David Okun IBM on 4/11/18.
//

import Foundation

struct SlackUser: Codable {
    var name: String
    var presence: String
    
    static func getActiveCount(token: String) throws -> (Int, Int)? { // (activeUsers, totalUsers)
        let url = URL(string: "https://slack.com/api/users.list?token=\(token)")
        do {
            let response = try Data(contentsOf: url!)
            let slackResponse = try JSONDecoder().decode(SlackResponse.self, from: response)
            if let _ = slackResponse.error {
                throw SlackResponseError.channelNotFound
            } else {
                guard let users = slackResponse.members else {
                    throw SlackResponseError.notAllowed
                }
                var activeCount = 0
                for user in users where user.presence == "active" {
                    activeCount = activeCount + 1
                }
                return (activeCount, users.count)
            }
        } catch let error {
            throw error
        }
    }
}
