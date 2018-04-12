//
//  SlackChannel.swift
//  slackin-swift
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation

struct SlackChannel: Codable {
    var id: String
    var name: String
    
    static func getAll(token: String) throws -> [SlackChannel]? {
        let url = URL(string: "https://slack.com/api/channels.list?token=\(token)")
        do {
            let response = try Data(contentsOf: url!)
            let decoder = JSONDecoder()
            let slackResponse = try decoder.decode(SlackResponse.self, from: response)
            if let _ = slackResponse.error {
                throw SlackResponseError.channelNotFound
            } else {
                return slackResponse.channels
            }
        } catch let error {
            throw error
        }
    }
}
