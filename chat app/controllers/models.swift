//
//  models.swift
//  chat app
//
//  Created by faisal on 02/06/1443 AH.
//

import Foundation
import MessageKit
import InputBarAccessoryView
// MARK: - message model
struct Message: MessageType {
    
    public var sender: SenderType // sender for each message
    public var messageId: String // id to de duplicate
    public var sentDate: Date // date time
    public var kind: MessageKind // text, photo, video, location, emoji
}
extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
// MARK: - sender model
struct Sender: SenderType {
    public var photoURL: String // extend with photo URL
    public var senderId: String
    public var displayName: String
    
    
}
