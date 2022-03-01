//
//  InAppMessageView.swift
//  GoPushSDK
//
//  Created by Ненад Љубиќ on 7.2.22.
//

import UIKit

final class InAppMessageView: UIView {
    
    private(set) var collectionView: UICollectionView!
    private(set) var blocks = [BlockElement]()
    private var layout: Layout!
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.isUserInteractionEnabled = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    init(layout: Layout) {
        super.init(frame: .zero)
        self.layout = layout
        layout == .carousel ? setupViewsForCarouselType() : setupViews()
        layout == .carousel ? setupConstraintsForCarouselType() : setupConstraints(layout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setting Up Views And Constraints For Other Layout Types
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.addSubview(stackView)
    }
    
    private func setupConstraints(layout: Layout) {
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
                
        switch layout {
        case .top, .bottom:
            scrollView.heightAnchor.constraint(equalTo: self.stackView.heightAnchor).isActive = true
        case .center, .full, .carousel:
            break
        }
    }
    
    // MARK: - Setting Up Views And Constraints For Other Carousel Type
    private func setupViewsForCarouselType() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionView)
    }
    
    private func setupConstraintsForCarouselType() {
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }
    
    // MARK: - Setting Up Blocks Depending The Layout Type
    func setBlocks(blocks: [BlockElement]) {
        self.blocks = blocks
        
        layout == .carousel ? collectionView.reloadData() : addBlocksToStackView()
    }
    
    private func addBlocksToStackView() {
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

// MARK: - UICollectionView, UICollectionViewDataSource, UICollectionViewFlowLayout Delegate Methods
extension InAppMessageView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarouselCollectionViewCell
        cell.setupCell(blocks: blocks)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: frame.size.height)
    }
}
