//
//  InAppManager.swift
//  GoPushSDK
//
//  Created by Ненад Љубиќ on 27.1.22.
//

import Foundation
import UIKit
import Kingfisher

public enum MessageLayoutType {
    case top
    case center
    case bottom
    case full
    case carousel
}

protocol InAppManagerDelegate {
    func blockTappedWithLocationPrompt()
}

class InAppManager {
    
    static var socketData: SocketData?
    
    static var delegate: InAppManagerDelegate?
    
    static func createInAppMessageView(socketData: SocketData?) -> UIView? {
        guard let blocks = socketData?.blocks, let layout = socketData?.layoutType else { print("Cannot read json. SocketData is nil"); return nil}
        
        self.socketData = socketData
        holderView.addSubview(closeButton)
        closeButton.isHidden = !(socketData?.closeButton?.show ?? false)
        
        closeButton.topAnchor.constraint(equalTo: holderView.topAnchor, constant: 10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: holderView.trailingAnchor, constant: -10).isActive = true
        
        let inAppMessageView = InAppMessageView(layout: layout)
        inAppMessageView.setBlocks(blocks: blocks)
        
        holderView.addSubview(inAppMessageView)

        let topAnchorStackView: NSLayoutAnchor = socketData?.closeButton?.show ?? false ? closeButton.bottomAnchor : holderView.topAnchor
        let constant : CGFloat = socketData?.closeButton?.show ?? false ? 5 : 10

        inAppMessageView.topAnchor.constraint(equalTo: topAnchorStackView, constant: constant).isActive = true
        inAppMessageView.bottomAnchor.constraint(equalTo: holderView.bottomAnchor, constant: -10).isActive = true
        inAppMessageView.trailingAnchor.constraint(equalTo: holderView.trailingAnchor, constant: -10).isActive = true
        inAppMessageView.leadingAnchor.constraint(equalTo: holderView.leadingAnchor, constant: 10).isActive = true

        return holderView
    }

}

// MARK: - Extension For UI Elements
extension InAppManager {
    static var holderView: UIView = {
        let holderView = UIView()
        holderView.backgroundColor = .white
        holderView.layer.cornerRadius = 8
        holderView.layer.shadowColor = UIColor.black.cgColor
        holderView.layer.shadowOpacity = 0.3
        holderView.layer.shadowOffset = .zero
        holderView.layer.shadowRadius = 3

        return holderView
    }()

    static var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.isUserInteractionEnabled = true
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    static var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "closeIcon", in: Bundle(for: InAppManager.self), with: nil), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false


        return button
    }()

    static func createButton(blockElement: BlockElement) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 45))
        button.setTitle(blockElement.text ?? "", for: .normal)
        button.layer.cornerRadius = 8


        button.backgroundColor = UIColor(hex: blockElement.background ?? "")

        button.translatesAutoresizingMaskIntoConstraints = false

        button.heightAnchor.constraint(equalToConstant: 45).isActive = true

        button.setAttributedTitle(getAttributedString(blockElement: blockElement), for: .normal)

        button.accessibilityValue = blockElement.actions?.url
        button.tag = blockElement.actions?.locationPermissionPrompt ?? false ? 1 : 0

        button.addTarget(self, action: #selector(blockElementTapAction(sender:)), for: .touchUpInside)

        return button
    }

    static func createTextView(blockElement: BlockElement) -> UITextView {
        let textView = UITextView()

        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.isEditable = false
        textView.text = blockElement.text ?? ""

        let margins = UIEdgeInsets(top: CGFloat(blockElement.margin?.top ?? 0), left: CGFloat(blockElement.margin?.left ?? 0), bottom: -(CGFloat(blockElement.margin?.bottom ?? 0)), right: -(CGFloat(blockElement.margin?.right ?? 0)))
        textView.contentInset = margins

        textView.attributedText = getAttributedString(blockElement: blockElement)

//        if let backgroundColor = blockElement.background {
//            textView.backgroundColor = UIColor(hex: backgroundColor)
//        }

        return textView
    }

    static func createImageView(blockElement: BlockElement) -> UIImageView {
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        
        if let imageName = blockElement.imageName {
            imageView.kf.setImage(with: URL(string: imageName))
        }

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        imageView.isUserInteractionEnabled = true

        imageView.tag = blockElement.actions?.locationPermissionPrompt ?? false ? 1 : 0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(sender:)))
        tapGesture.accessibilityValue = blockElement.actions?.url
        tapGesture.accessibilityHint = blockElement.actions?.locationPermissionPrompt ?? false ? "1" : "0"
        
        imageView.addGestureRecognizer(tapGesture)

        return imageView
    }
}

// MARK: - Utilities
extension InAppManager {
    static func getAttributedString(blockElement: BlockElement?) -> NSMutableAttributedString {
        
        let fontSize = CGFloat(Int(blockElement?.format?.size ?? "0") ?? 0)
        let systemFont = UIFont.systemFont(ofSize: fontSize)

        let attributedString = NSMutableAttributedString(string: blockElement?.text ?? "")
        var attributes = [NSAttributedString.Key:Any]()
        
        let textColor = UIColor(hex: blockElement?.color ?? "#000000")


        attributedString.beginEditing()
        if blockElement?.format?.underline ?? false { attributes[.underlineStyle] = 1.0 }

        var traits = UIFontDescriptor.SymbolicTraits()

        if blockElement?.format?.bold ?? false { traits.insert(.traitBold) }

        if blockElement?.format?.italic ?? false { traits.insert(.traitItalic) }

        if let descriptor = systemFont.fontDescriptor.withSymbolicTraits(traits) {
            let systemFontBoldAndItalic = UIFont(descriptor: descriptor, size: fontSize)
            attributes[.font] = systemFontBoldAndItalic
            attributes[.foregroundColor] = textColor
            let style = NSMutableParagraphStyle()
            style.alignment = blockElement?.textAlignment == .right ? .right : blockElement?.textAlignment == .center ? .center : .left
            attributes[.paragraphStyle] = style
            attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
        }

        attributedString.endEditing()

        return attributedString
    }

    @objc static func blockElementTapAction(sender: UIView?) {
        if let stringURL = sender?.accessibilityValue, let url = URL(string: stringURL) {
            UIApplication.shared.open(url)
        }
        
        if let senderTag = sender?.tag, senderTag == 1 {
            delegate?.blockTappedWithLocationPrompt()
        }
    }
    
    @objc static func tapGestureAction(sender: UITapGestureRecognizer) {
        if let stringURL = sender.accessibilityValue, let url = URL(string: stringURL) {
            UIApplication.shared.open(url)
        }
        
        if let locationPrompt = sender.accessibilityHint, locationPrompt == "1" {
            delegate?.blockTappedWithLocationPrompt()
        }
    }
}
