//
//  SlackChannel.swift
//  slackin-swift
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation
import LoggerAPI
import SwiftyRequest

struct SlackChannel: Codable {
    var id: String
    var name: String
    
    static func getAll(token: String, completion: @escaping (_ channels: [SlackChannel]?, _ error: Error?) -> Void) {
        Log.verbose("Requesting channel info")
        let url = "https://slack.com/api/channels.list?token=\(token)"
        Log.verbose("Attempting to retrieve channel information from url: \(url)")
        let request = RestRequest(method: .get, url: url, containsSelfSignedCert: false)
        request.responseObject { (response: RestResponse<SlackResponse>) in
            switch response.result {
            case .success(let slackResponse):
                if (slackResponse.error != nil) {
                    completion(nil, SlackResponseError.channelNotFound)
                } else {
                    completion(slackResponse.channels, nil)
                }
                break
            case .failure(let error):
                Log.error("Error received from Slack API during channel retrieval: \(String(describing: error))")
                completion(nil, error)
                break
            }
        }
    }
}
