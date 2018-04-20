//
//  SlackChannel.swift
//  slackin-swift
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation
import LoggerAPI

struct SlackChannel: Codable {
    var id: String
    var name: String
    
    static func getAll(token: String) throws -> [SlackChannel]? {
        Log.verbose("Requesting channel info")
        let url = URL(string: "https://slack.com/api/channels.list?token=\(token)")
        do {
            Log.verbose("Attempting to retrieve channel information from url: \(String(describing: url))")
            let response = try Data(contentsOf: url!)
            Log.verbose("Attempting to decode channel response")
            let slackResponse = try JSONDecoder().decode(SlackResponse.self, from: response)
            if let _ = slackResponse.error {
                Log.error("Error received from Slack API during channel retrieval: \(String(describing: slackResponse.error))")
                throw SlackResponseError.channelNotFound
            } else {
                return slackResponse.channels
            }
        } catch let error {
            Log.error("Error retrieving channels: \(error.localizedDescription)")
            throw error
        }
    }
}
