//
//  SlackRoutes.swift
//  slackin-swift
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation
import KituraContracts
import LoggerAPI
import Dispatch
import SwiftyRequest

private var requestToken: String?

func initializeSlackRoutes(app: App) {
    requestToken = app.token
    app.router.get("/api/invite/", handler: inviteHandler)
    app.router.get("/api/channels", handler: channelHandler)
    app.router.get("/api/team", handler: teamHandler)
    Log.info("Slack API routes registered")
}

private func inviteHandler(email: String, completion: @escaping (SlackResponse?, RequestError?) -> Void) {
    Log.verbose("Attempting to invite email: \(email)")
    Log.verbose("Checking presence of token")
    guard let token = requestToken else {
        Log.error("Error processing invite - No token found")
        return completion(nil, RequestError.unauthorized)
    }
    SlackChannel.getAll(token: token) { channels, error in
        guard let channels = channels else {
            Log.error("Error retrieving slack channels - collection is nil")
            return completion(nil, error as? RequestError)
        }
        var approvedChannels = ""
        for channel in channels where channel.name == "general" {
            approvedChannels.append("\(channel.id),")
        }
        Log.verbose("approved channels count: \(approvedChannels.count)")
        let url = "https://slack.com/api/users.admin.invite?token=\(token)&email=\(email)&channels=\(approvedChannels.dropLast())"
        let request = RestRequest(method: .get, url: url, containsSelfSignedCert: false)
        request.responseObject { (response: RestResponse<SlackResponse>) in
            switch response.result {
            case .success(let slackResponse):
                if let responseError = slackResponse.error {
                    Log.error("Slack invitation API returned error: \(responseError)")
                    completion(nil, .badRequest)
                } else {
                    Log.verbose("Successful invitation response")
                    completion(slackResponse, nil)
                }
            case .failure(let error):
                Log.error("Slack invitation request error: \(error.localizedDescription)")
                completion(nil, error as? RequestError)
            }
        }
    }
}

private func channelHandler(completion: @escaping ([SlackChannel]?, RequestError?) -> Void) {
    guard let token = requestToken else {
        Log.error("Error processing channel request - No token found")
        completion(nil, RequestError.unauthorized)
        return
    }
    SlackChannel.getAll(token: token) { channels, error in
        completion(channels, error as? RequestError)
    }
}

private func teamHandler(completion: @escaping (SlackTeam?, RequestError?) -> Void) {
    guard let token = requestToken else {
        Log.error("Error processing team request - No token found")
        completion(nil, RequestError.unauthorized)
        return
    }
    SlackTeam.getInfo(token: token) { team, error in
        completion(team, error as? RequestError)
    }
}
