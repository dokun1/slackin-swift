//
//  SlackUser.swift
//  Application
//
//  Created by David Okun IBM on 4/11/18.
//

import Foundation
import LoggerAPI
import SwiftyRequest

struct SlackUserCount: Codable {
    var activeCount: Int
    var totalCount: Int
}

struct SlackUser: Codable {
    var name: String?
    var presence: String?
    
    static func getActiveCount(token: String, teamInfo: SlackTeam, completion: @escaping (_ userCount: SlackUserCount?, _ error: Error?) -> Void) { // (activeUsers, totalUsers)
        Log.verbose("Requesting user info")
        let url = "https://\(teamInfo.domain).slack.com/api/users.list?token=\(token)&presence=1"
        Log.verbose("Attempting to retrieve user information from url: \(String(describing: url))")
        let request = RestRequest(method: .get, url: url, containsSelfSignedCert: false)
        request.responseObject { (response: RestResponse<SlackResponse>) in
            switch response.result {
            case .success(let slackResponse):
                if let responseError = slackResponse.error {
                    Log.error("Slack API error from user info request: \(responseError)")
                    completion(nil, SlackResponseError.notAllowed)
                } else {
                    guard let users = slackResponse.members else {
                        Log.error("Could not retrieve user collection from slack response")
                        return completion(nil, SlackResponseError.notAllowed)
                    }
                    var activeCount = 0
                    for user in users where user.presence == "active" {
                        activeCount = activeCount + 1
                    }
                    completion(SlackUserCount(activeCount: activeCount, totalCount: users.count), nil)
                }
            case .failure(let error):
                Log.error("Error received from Slack API during user info retrieval: \(String(describing: error))")
                completion(nil, error)
            }
        }
    }
}
