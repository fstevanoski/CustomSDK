//
//  CarouselCollectionViewCell.swift
//  GoPushSDK
//
//  Created by Ненад Љубиќ on 8.2.22.
//

import UIKit

final class CarouselCollectionViewCell: UICollectionViewCell {

    private(set) var stackView: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView = UIStackView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.isUserInteractionEnabled = true
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
    }

    private func setupConstraints() {
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5).isActive = true
    }

    func setupCell(blocks: [BlockElement]) {

        for element in blocks {
            switch element.blockType {
            case .button:
                stackView.addArrangedSubview(InAppManager.createButton(blockElement: element))
            case .text:
                stackView.addArrangedSubview(InAppManager.createTextView(blockElement: element))
            case .image:
                stackView.addArrangedSubview(InAppManager.createImageView(blockElement: element))
            case .none:
                break
            }
        }
        stackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 0)))
    }
}
