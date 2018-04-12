//
//  SlackRoutes.swift
//  slackin-swift
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation
import KituraContracts

var requestToken: String?

func initializeSlackRoutes(app: App) {
    requestToken = app.token
    app.router.get("/api/invite/", handler: inviteHandler)
    app.router.get("/api/channels", handler: channelHandler)
    app.router.get("/api/team", handler: teamHandler)
}

private func inviteHandler(email: String, completion: @escaping (SlackResponse?, RequestError?) -> Void) {
    guard let token = requestToken else {
        return completion(nil, RequestError.unauthorized)
    }
    do {
        guard let channels = try SlackChannel.getAll(token: token) else {
            return completion(nil, .badRequest)
        }
        var approvedChannels = ""
        for channel in channels where channel.name == "general" {
            approvedChannels.append("\(channel.id),")
        }
        
        guard let url = URL(string: "https://slack.com/api/users.admin.invite?token=\(token)&email=\(email)&channels=\(approvedChannels.dropLast())") else {
            return completion(nil, .badRequest)
        }
        do {
            let response = try Data(contentsOf: url)
            let slackResponse = try JSONDecoder().decode(SlackResponse.self, from: response)
            if let _ = slackResponse.error {
                completion(nil, .unauthorized)
            } else {
                completion(slackResponse, nil)
            }
        } catch let error {
            completion(nil, RequestError(rawValue: 404, reason: error.localizedDescription))
        }
    } catch {
        completion(nil, .badRequest)
    }
}

private func channelHandler(completion: @escaping ([SlackChannel]?, RequestError?) -> Void) {
    guard let token = requestToken else {
        completion(nil, RequestError.unauthorized)
        return
    }
    do {
        let channels = try SlackChannel.getAll(token: token)
        completion(channels, nil)
    } catch let error {
        completion(nil, RequestError(rawValue: 404, reason: error.localizedDescription))
    }
}

private func teamHandler(completion: @escaping (SlackTeam?, RequestError?) -> Void) {
    guard let token = requestToken else {
        completion(nil, RequestError.unauthorized)
        return
    }
    do {
        let team = try SlackTeam.getInfo(token: token)
        completion(team, nil)
    } catch let error {
        completion(nil, RequestError(rawValue: 404, reason: error.localizedDescription))
    }
}
