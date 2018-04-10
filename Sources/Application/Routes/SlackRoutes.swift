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
    app.router.get("/api/channels", handler: getChannels)
    app.router.get("/api/invite/", handler: inviteHandler)
    app.router.get("/api/team)", handler: teamHandler)
}

private func inviteHandler(email: String, completion: @escaping (SlackResponse?, RequestError?) -> Void) {
    getChannels { (channels: [SlackChannel]?, error: RequestError?) in
        if let error = error {
            completion(nil, RequestError(rawValue: 404, reason: error.localizedDescription))
            return
        }
        guard let channels = channels else {
            completion(nil, .notFound)
            return
        }
        var approvedChannels = ""
        for channel in channels where channel.name == "general" {
            approvedChannels.append("\(channel.id),")
        }
        guard let token = requestToken else {
            completion(nil, RequestError.unauthorized)
            return
        }
        guard let url = URL(string: "https://slack.com/api/users.admin.invite?token=\(token)&email=\(email)&channels=\(approvedChannels.dropLast())") else {
            completion(nil, RequestError.badRequest)
            return
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
    }
}

private func getChannels(completion: @escaping ([SlackChannel]?, RequestError?) -> Void) {
    guard let token = requestToken else {
        completion(nil, RequestError.unauthorized)
        return
    }
    let url = URL(string: "https://slack.com/api/channels.list?token=\(token)")
    do {
        let response = try Data(contentsOf: url!)
        let decoder = JSONDecoder()
        let slackResponse = try decoder.decode(SlackResponse.self, from: response)
        if let _ = slackResponse.error {
            completion(nil, .unauthorized)
        } else {
            completion(slackResponse.channels, nil)
        }
    } catch let error {
        completion(nil, RequestError(rawValue: 404, reason: error.localizedDescription))
    }
}

private func teamHandler(completion: @escaping(SlackTeam?, RequestError?) -> Void) {
    guard let token = requestToken else {
        completion(nil, RequestError.unauthorized)
        return
    }
    let url = URL(string: "https://slack.com/api/team.info?token=\(token)")
    do {
        let response = try Data(contentsOf: url!)
        let decoder = JSONDecoder()
        let slackResponse = try decoder.decode(SlackResponse.self, from: response)
        if let _ = slackResponse.error {
            completion(nil, .unauthorized)
        } else {
            completion(slackResponse.team, nil)
        }
    } catch let error {
        completion(nil, RequestError(rawValue: 404, reason: error.localizedDescription))
    }
}
