//
//  BlockElement.swift
//  GoPushSDK
//
//  Created by Ненад Љубиќ on 27.1.22.
//

import Foundation

enum BlockType: String, Codable {
    case text = "text"
    case image = "image"
    case button = "button"
}

enum TextAlignment: String, Codable {
    case center = "center"
    case right = "right"
    case left = "left"
}

public struct BlockElement: Codable {
    var type: String?
    var format: TextFormat?
    var text: String?
    var background: String?
    var imageName: String?
    var actions: Action?
    var margin: Margin?
    var color: String?
    var alignment: String?

    var blockType: BlockType? {
        return BlockType(rawValue: type ?? "")
    }
    
    var textAlignment: TextAlignment {
        return TextAlignment(rawValue: alignment ?? "") ?? .center
    }

    enum CodingKeys: String, CodingKey {
        #warning("Handle The cases for text and imagename")
        case imageName = "src"
        case type = "type"
        case text = "text"
        case background = "background"
        case format = "format"
        case actions = "action"
        case margin = "margin"
        case color = "colour"
        case alignment = "alignment"
    }
}

public struct Action: Codable {
    var url: String?
    var locationPermissionPrompt: Bool?
}

public struct Margin: Codable {
    var top: Int?
    var right: Int?
    var left: Int?
    var bottom: Int?
}
