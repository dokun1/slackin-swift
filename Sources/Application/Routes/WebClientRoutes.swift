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

func initializeWebClientRoutes(app: App) {
    app.router.setDefault(templateEngine: StencilTemplateEngine())
    app.router.all(middleware: StaticFileServer())
    app.router.get("/") { _, response, _ in
        do {
            guard let token = app.token else {
                try response.status(.internalServerError).render("error", context: ["error": "Token not found"])
                return
            }
            guard let channels = try SlackChannel.getAll(token: token) else {
                try response.status(.internalServerError).render("error", context: ["error": "Token not valid"])
                return
            }
            guard let team = try SlackTeam.getInfo(token: token) else {
                try response.status(.internalServerError).render("error", context: ["error": "Team not valid"])
                return
            }
            // this method seems to really have some terrible rate limiting, so mocking the data below until i figure out why
//            guard let userCount = try SlackUser.getActiveCount(token: token) else {
//                try response.status(.internalServerError).render("error", context: ["error": "Users not loaded"])
//                return
//            }
            let userCount = (2, 40)
            let validList = channels.contains { element in
                return element.name == "general"
            }
            if validList {
                try response.status(.OK).render("home", context: ["slackDomain" : team.domain,"slackTeamName": team.name, "slackIconURL": team.icon.image_88, "usersOnline": userCount.0, "usersRegistered": userCount.1])
            } else {
                throw SlackResponseError.channelNotFound
            }
        } catch let error {
            try response.status(.internalServerError).render("error", context: ["error": "uncaught exception: \(error.localizedDescription)"])
            return
        }
    }
}

