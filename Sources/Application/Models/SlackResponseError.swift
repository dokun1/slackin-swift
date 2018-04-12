//
//  SlackResponseError.swift
//  Application
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation

enum SlackResponseError: Error {
    case alreadyInvited
    case alreadyInTeam
    case channelNotFound
    case sentRecently
    case userDisabled
    case missingScope
    case invalidEmail
    case notAllowed
    case notAllowedTokenType
    case unknown
    
    static func classify(message: String) -> SlackResponseError {
        switch message {
        case "already_invited":
            return .alreadyInvited
        case "already_in_team":
            return .alreadyInTeam
        case "channel_not_found":
            return .channelNotFound
        case "sent_recently":
            return .sentRecently
        case "user_disabled":
            return .userDisabled
        case "missing_scope":
            return .missingScope
        case "invalid_email":
            return .invalidEmail
        case "not_allowed":
            return .notAllowed
        case "not_allowed_token_type":
            return .notAllowedTokenType
        default:
            return .unknown
        }
    }
}
