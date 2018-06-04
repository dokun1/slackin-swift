//
//  SlackTeam.swift
//  Application
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation
import LoggerAPI
import SwiftyRequest

struct SlackTeamIcon: Codable {
    var smallImageURL: String
    var mediumImageURL: String
    var largeImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case smallImageURL = "image_34"
        case mediumImageURL = "image_102"
        case largeImageURL = "image_original"
    }
}

struct SlackTeam: Codable {
    var id: String
    var name: String
    var domain: String
    var icon: SlackTeamIcon

    static func getInfo(token: String, completion: @escaping (_ team: SlackTeam?, _ error: Error?) -> Void) {
        Log.verbose("Requesting team info")
        let url = "https://slack.com/api/team.info?token=\(token)"
        Log.verbose("Attempting to retrieve team information from url: \(url)")
        let request = RestRequest(method: .get, url: url, containsSelfSignedCert: false)
        request.responseObject { (response: RestResponse<SlackResponse>) in
            switch response.result {
            case .success(let slackResponse):
                if let responseError = slackResponse.error {
                    Log.error("Slack API error from team request: \(responseError)")
                    completion(nil, SlackResponseError.notAllowed)
                } else {
                    completion(slackResponse.team, nil)
                }
            case .failure(let error):
                Log.error("Error received from Slack API during team retrieval: \(String(describing: error))")
                completion(nil, error)
            }
        }
    }
}
