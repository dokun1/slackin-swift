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
            try response.status(.internalServerError).render("error", context: ["error": "Token not found"])
            return
        }
        var storedChannels: [SlackChannel]?, storedTeam: SlackTeam?, storedUserCount: (Int, Int)?
        let slackRequestGroup = DispatchGroup()
        Log.verbose("Attempting to fetch channels")
        slackRequestGroup.enter()
        SlackChannel.getAll(token: token) { channels, error in
            if let channels = channels {
                storedChannels = channels
            }
            slackRequestGroup.leave()
        }
        slackRequestGroup.enter()
        SlackTeam.getInfo(token: token) { team, error in
            if let team = team {
                storedTeam = team
            }
            slackRequestGroup.leave()
        }
        slackRequestGroup.enter()
        SlackUser.getActiveCount(token: token) { userCount, error in
            if let userCount = userCount {
                storedUserCount = userCount
            }
            slackRequestGroup.leave()
        }
        slackRequestGroup.notify(queue: DispatchQueue.global(qos: .default), execute: {
            serveClientPage(channels: storedChannels, team: storedTeam, users: storedUserCount, response: response)
        })
//        slackRequestGroup.notify(queue: DispatchQueue.global(qos: .default), work: serveClientPage(channels: storedChannels, team: storedTeam, users: storedUserCount, response: response))
    } catch let error {
        Log.error(error.localizedDescription)
        try! response.status(.internalServerError).render("error", context: ["error": "uncaught exception: \(error.localizedDescription)"])
    }
}

private func serveClientPage(channels: [SlackChannel]?, team: SlackTeam?, users: (Int, Int)?, response: RouterResponse) {
    do {
        guard let channels = channels else {
            try response.status(.internalServerError).render("error", context: ["error": "could not load channels"])
            return
        }
        guard let team = team else {
            try response.status(.internalServerError).render("error", context: ["error": "could not load team info"])
            return
        }
//        guard let users = users else {
//            try response.status(.internalServerError).render("Error", context: ["error": "could not load available user list"])
//            return
//        }
        let newUsers = (5, 40)
        let validList = channels.contains { element in
            return element.name == "general"
        }
        if validList {
            try response.status(.OK).render("home", context: ["slackDomain" : team.domain,"slackTeamName": team.name, "slackIconURL": team.icon.image_88, "usersOnline": newUsers.0, "usersRegistered": newUsers.1])
        } else {
            Log.error("throwing exception - invalid channel list")
            throw SlackResponseError.channelNotFound
        }
    } catch let error {
        Log.error(error.localizedDescription)
        try! response.status(.internalServerError).render("error", context: ["error": "uncaught exception: \(error.localizedDescription)"])
    }
}

