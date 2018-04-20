//
//  SlackTeam.swift
//  Application
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation
import LoggerAPI

struct SlackTeamIcon: Codable {
    var image_34: String
    var image_44: String
    var image_68: String
    var image_88: String
    var image_102: String
    var image_132: String
    var image_230: String
    var image_original: String
}

struct SlackTeam: Codable {
    var id: String
    var name: String
    var domain: String
    var icon: SlackTeamIcon
    
    static func getInfo(token: String) throws -> SlackTeam? {
        Log.verbose("Requesting team info")
        let url = URL(string: "https://slack.com/api/team.info?token=\(token)")
        do {
            Log.verbose("Attempting to retrieve team information from url: \(String(describing: url))")
            let response = try Data(contentsOf: url!)
            Log.verbose("Attempting to decode team response")
            let slackResponse = try JSONDecoder().decode(SlackResponse.self, from: response)
            if let _ = slackResponse.error {
                Log.error("Error received from Slack API during team retrieval: \(String(describing: slackResponse.error))")
                throw SlackResponseError.channelNotFound
            } else {
                return slackResponse.team
            }
        } catch let error {
            Log.error("Error retrieving team: \(error.localizedDescription)")
            throw error
        }
    }
}
