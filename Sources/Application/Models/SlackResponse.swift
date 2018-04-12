//
//  SlackResponse.swift
//  slackin-swift
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation

struct SlackResponse: Codable {
    var ok: Bool
    var channels: [SlackChannel]?
    var error: String?
    var team: SlackTeam?
    var members: [SlackUser]?
}
