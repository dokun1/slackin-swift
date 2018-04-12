//
//  SlackTeam.swift
//  Application
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation

struct SlackTeam: Codable {
    var id: String
    var name: String
    var domain: String
    
    static func getInfo(token: String) throws -> SlackTeam? {
        let url = URL(string: "https://slack.com/api/team.info?token=\(token)")
        do {
            let response = try Data(contentsOf: url!)
            let slackResponse = try JSONDecoder().decode(SlackResponse.self, from: response)
            if let _ = slackResponse.error {
                throw SlackResponseError.channelNotFound
            } else {
                return slackResponse.team
            }
        } catch let error {
            throw error
        }
    }
}
