//
//  ViewController.swift
//  TransitionsExample
//
//  Created by Stanly Shiyanovskiy on 4/19/19.
//  Copyright © 2019 Stanly Shiyanovskiy. All rights reserved.
//

import UIKit

public class ViewController: UIViewController {
    
    // UI elements
    private var photosCollectionView: PhotosCollectionView!
    
    private var sweetAnimator = SweetAnimator()
    private var hideSelectedCell: Bool = false
    
    // Data
    private var photos: [UIImage]!
    private var selectedIndex: Int?
    
    public override func loadView() {
        super.loadView()
        
        configurePhotosSource()
        configureCollectionView()
    }
    
    private func configurePhotosSource() {
        photos = [UIImage]()
        for i in 1...9 {
            let imageName = "0\(i).jpg"
            guard let image = UIImage(named: imageName) else { return }
            photos.append(image)
        }
    }
    
    private func configureCollectionView() {
        photosCollectionView = PhotosCollectionView(with: self)
        self.view.addSubview(photosCollectionView)
        
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photosCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        photosCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        photosCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        photosCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func showPreview() {
        guard let photos = photos else { return }
        let previewView = PhotoPreviewController()
        previewView.transitioningDelegate = self
        previewView.setupWithPhotos(delegate: self, photos: photos, selectedPhotoIndex: selectedIndex!)
        present(previewView, animated: true, completion: nil)
    }
}

extension ViewController: PreviewDelegate {
    public var photosSource: [UIImage] {
        return photos
    }
    
    public func updateSelectedIndex(newIndex index: Int) {
        selectedIndex = index
        showPreview()
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let previewView = presented as! PhotoPreviewController
        sweetAnimator.setupImageTransition(image: photos[selectedIndex!], fromDelegate: self, toDelegate: previewView)
        return sweetAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let previewView = dismissed as! PhotoPreviewController
        sweetAnimator.setupImageTransition(image: photos[selectedIndex!], fromDelegate: previewView, toDelegate: self)
        return sweetAnimator
    }
}

extension ViewController: ImageTransitionProtocol {
    
    public func tranisitionSetup(){
        hideSelectedCell = true
        photosCollectionView.reloadData()
    }
    
    public func tranisitionCleanup(){
        hideSelectedCell = false
        photosCollectionView.reloadData()
    }
    
    public func imageWindowFrame() -> CGRect{
        let indexPath = IndexPath(row: selectedIndex!, section: 0)
        let attributes = photosCollectionView.layoutAttributesForItem(at: indexPath as IndexPath)
        let cellRect = photosCollectionView.convert(attributes!.frame, to: photosCollectionView.superview)
        return cellRect
    }
}

