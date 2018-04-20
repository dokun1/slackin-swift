//
//  SlackRoutes.swift
//  slackin-swift
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation
import KituraContracts
import LoggerAPI

var requestToken: String?

func initializeSlackRoutes(app: App) {
    requestToken = app.token
    app.router.get("/api/invite/", handler: inviteHandler)
    app.router.get("/api/channels", handler: channelHandler)
    app.router.get("/api/team", handler: teamHandler)
}

private func inviteHandler(email: String, completion: @escaping (SlackResponse?, RequestError?) -> Void) {
    guard let token = requestToken else {
        Log.error("Error processing invite - No token found")
        return completion(nil, RequestError.unauthorized)
    }
    do {
        Log.verbose("Attempting to fetch channels")
        guard let channels = try SlackChannel.getAll(token: token) else {
            Log.error("Error processing invite - no channels list retrieved")
            return completion(nil, .badRequest)
        }
        var approvedChannels = ""
        for channel in channels where channel.name == "general" {
            approvedChannels.append("\(channel.id),")
        }
        Log.verbose("approved channels count: \(approvedChannels.count)")
        guard let url = URL(string: "https://slack.com/api/users.admin.invite?token=\(token)&email=\(email)&channels=\(approvedChannels.dropLast())") else {
            return completion(nil, .badRequest)
        }
        Log.verbose("invite url: \(String(describing: url))")
        do {
            let response = try Data(contentsOf: url)
            Log.verbose("Received response from invite URL")
            let slackResponse = try JSONDecoder().decode(SlackResponse.self, from: response)
            if let _ = slackResponse.error {
                Log.error("Could not decode invite response")
                completion(nil, .unauthorized)
            } else {
                Log.info("Successfully decoded invite response")
                completion(slackResponse, nil)
            }
        } catch let error {
            Log.error("Error processing invite - \(error.localizedDescription)")
            completion(nil, RequestError(rawValue: 404, reason: error.localizedDescription))
        }
    } catch {
        completion(nil, .badRequest)
    }
}

private func channelHandler(completion: @escaping ([SlackChannel]?, RequestError?) -> Void) {
    guard let token = requestToken else {
        Log.error("Error processing channel request - No token found")
        completion(nil, RequestError.unauthorized)
        return
    }
    do {
        let channels = try SlackChannel.getAll(token: token)
        completion(channels, nil)
    } catch let error {
        Log.error("Error fetching channels: \(error.localizedDescription)")
        completion(nil, RequestError(rawValue: 404, reason: error.localizedDescription))
    }
}

private func teamHandler(completion: @escaping (SlackTeam?, RequestError?) -> Void) {
    guard let token = requestToken else {
        Log.error("Error processing team request - No token found")
        completion(nil, RequestError.unauthorized)
        return
    }
    do {
        let team = try SlackTeam.getInfo(token: token)
        completion(team, nil)
    } catch let error {
        Log.error("Error fetching teams: \(error.localizedDescription)")
        completion(nil, RequestError(rawValue: 404, reason: error.localizedDescription))
    }
}
