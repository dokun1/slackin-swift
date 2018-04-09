//
//  SlackChannel.swift
//  slackin-swift
//
//  Created by David Okun IBM on 4/9/18.
//

import Foundation

struct SlackChannel: Codable {
    var id: String
    var name: String
}

/*{
 "id": "CA385NMK6",
 "name": "brag-about-my-stuff",
 "is_channel": true,
 "created": 1523279850,
 "is_archived": false,
 "is_general": false,
 "unlinked": 0,
 "creator": "U4WGXJ7B9",
 "name_normalized": "brag-about-my-stuff",
 "is_shared": false,
 "is_org_shared": false,
 "is_member": true,
 "is_private": false,
 "is_mpim": false,
 "members": [
 "U4VQ0TUN7",
 "U4WGXJ7B9",
 "U5BSX4UM7",
 "U6J2WGQG4"
 ],
 "topic": {
 "value": "",
 "creator": "",
 "last_set": 0
 },
 "purpose": {
 "value": "People do awesome things - show them off here :slightly_smiling_face:",
 "creator": "U4WGXJ7B9",
 "last_set": 1523279851
 },
 "previous_names": [],
 "num_members": 4
 }, */
