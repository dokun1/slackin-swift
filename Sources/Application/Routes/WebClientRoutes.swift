//
//  WebClientRoutes.swift
//  Application
//
//  Created by David Okun IBM on 4/10/18.
//

import Foundation
import KituraContracts
import KituraStencil
import Kitura
import LoggerAPI

private var requestToken: String?

struct SlackWebContextError: Codable {
    var message: String
}

struct SlackWebContext: Codable {
    var slackDomain: String
    var slackTeamName: String
    var slackIconURL: String
    var usersOnline: Int
    var usersRegistered: Int
}

func initializeWebClientRoutes(app: App) {
    requestToken = app.token
    app.router.setDefault(templateEngine: StencilTemplateEngine())
    app.router.all(middleware: StaticFileServer())
    app.router.get("/", handler: handleWebClient)
}

func handleWebClient(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    do {
        Log.verbose("Checking token")
        guard let token = requestToken else {
            let error = SlackWebContextError(message: "Token not found")
            try response.status(.internalServerError).render("error.stencil", with: error, forKey: "error")
            return
        }
        var storedChannels: [SlackChannel]?, storedTeam: SlackTeam?, storedUserCount: SlackUserCount?
        let slackRequestGroup = DispatchGroup()
        slackRequestGroup.enter()
        SlackChannel.getAll(token: token) { channels, error in
            if let channels = channels {
                storedChannels = channels
            }
            slackRequestGroup.leave()
        }
        slackRequestGroup.enter()
        SlackTeam.getInfo(token: token) { teamInfo, error in
            if let teamInfo = teamInfo {
                storedTeam = teamInfo
                SlackUser.getActiveCount(token: token, teamInfo: teamInfo, completion: { userCount, error in
                    if let userCount = userCount {
                        storedUserCount = userCount
                    }
                    slackRequestGroup.leave()
                })
            } else {
                slackRequestGroup.leave()
            }
        }
        slackRequestGroup.notify(queue: DispatchQueue.global(qos: .default), execute: {
            serveClientPage(channels: storedChannels, team: storedTeam, users: storedUserCount, response: response)
        })
    } catch let error {
        Log.error(error.localizedDescription)
        let error = SlackWebContextError(message: "uncaught exception: \(error.localizedDescription)")
        try! response.status(.internalServerError).render("error.stencil", with: error, forKey: "error")
    }
}

private func serveClientPage(channels: [SlackChannel]?, team: SlackTeam?, users: SlackUserCount?, response: RouterResponse) {
    do {
        guard let channels = channels else {
            let error = SlackWebContextError(message: "Could not load channels")
            try response.status(.internalServerError).render("error.stencil", with: error, forKey: "error")
            return
        }
        guard let team = team else {
            let error = SlackWebContextError(message: "Could not load team info")
            try response.status(.internalServerError).render("error.stencil", with: error, forKey: "error")
            return
        }
        guard let users = users else {
            let error = SlackWebContextError(message: "Could not load available user list")
            try response.status(.internalServerError).render("error.stencil", with: error, forKey: "error")
            return
        }
        let validList = channels.contains { element in
            return element.name == "general"
        }
        if validList {
            let webContext = SlackWebContext(slackDomain: team.domain, slackTeamName: team.name, slackIconURL: team.icon.mediumImageURL, usersOnline: users.activeCount, usersRegistered: users.totalCount)
            try response.status(.OK).render("home.stencil", with: webContext, forKey: "context")
        } else {
            Log.error("throwing exception - invalid channel list")
            throw SlackResponseError.channelNotFound
        }
    } catch let error {
        Log.error(error.localizedDescription)
        let error = SlackWebContextError(message: "uncaught exception: \(error.localizedDescription)")
        try! response.status(.internalServerError).render("error.stencil", with: error, forKey: "error")
    }
}

