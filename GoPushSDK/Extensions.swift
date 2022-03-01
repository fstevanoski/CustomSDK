//
//  Extensions.swift
//  GoPushSDK
//
//  Created by Ненад Љубиќ on 2.2.22.
//

import Foundation
import UIKit

extension UIImageView {
    func load(url: URL?) {
        guard let imageURL = url else { return }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: imageURL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


extension UIColor {

    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1

        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }

        var color: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&color)

        switch hexFormatted.count {
        case 6:
            red = CGFloat((color & 0xFF0000) >> 16) / 255
            green = CGFloat((color & 0x00FF00) >> 8) / 255
            blue = CGFloat(color & 0x0000FF) / 255

        case 8:
            red = CGFloat((color & 0xFF000000) >> 24) / 255
            green = CGFloat((color & 0x00FF0000) >> 16) / 255
            blue = CGFloat((color & 0x0000FF00) >> 8) / 255
            alpha = CGFloat(color & 0x000000FF) / 255

        default:
            assertionFailure("Only hex values with 6 and 8 chars are supported")
            break
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
