//
//  PhotosCollectionView.swift
//  TransitionsExample
//
//  Created by Stanly Shiyanovskiy on 4/19/19.
//  Copyright © 2019 Stanly Shiyanovskiy. All rights reserved.
//

import UIKit

public class PhotosCollectionView: UICollectionView {

    public var heightValue: CGFloat {
        let height: CGFloat = 142.0
        let count = CGFloat(photosDelegate.photosSource.count)
        return count * (height + minimumLineSpacing) + minimumLineSpacing
    }

    private let minimumLineSpacing: CGFloat = 12.0
    
    private var photosDelegate: PreviewDelegate!
    
    public init(with photosDelegate: PreviewDelegate) {
        
        self.photosDelegate = photosDelegate
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        delegate = self
        dataSource = self
        
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        
        translatesAutoresizingMaskIntoConstraints = false
        layout.minimumLineSpacing = minimumLineSpacing
        contentInset = UIEdgeInsets(top: minimumLineSpacing, left: minimumLineSpacing, bottom: minimumLineSpacing, right: minimumLineSpacing)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotosCollectionView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        photosDelegate.updateSelectedIndex(newIndex: indexPath.row)
    }
}

extension PhotosCollectionView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosDelegate.photosSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // add image
        let photos = photosDelegate.photosSource
        let imageView = UIImageView(image: photos[indexPath.row])
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10.0
        
        // make cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
        cell.addSubview(imageView)
        
        // add image constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: cell.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        
        return cell
    }
}

extension PhotosCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 142.0, height: 142.0)
    }
}
