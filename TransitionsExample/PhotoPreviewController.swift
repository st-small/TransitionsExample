//
//  PhotoPreviewController.swift
//  TransitionsExample
//
//  Created by Stanly Shiyanovskiy on 4/19/19.
//  Copyright © 2019 Stanly Shiyanovskiy. All rights reserved.
//

import UIKit

public protocol PreviewDelegate {
    var photosSource: [UIImage] { get }
    func updateSelectedIndex(newIndex: Int)
}

public class PhotoPreviewController: UIViewController {

    // UI elements
    private var exitButton: UIButton!
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var contentWidthConstraint: NSLayoutConstraint!
    
    // data
    private var allPhotoScrollViews: Array<UIScrollView> = []
    private var allPhotos: Array<UIImage> = []
    private var currentPhotoIndex: Int = 0
    
    // delegate
    private var previewDelegate: PreviewDelegate?
    private var scrollViewDragging: Bool = false
    
    public func setupWithPhotos(delegate: PreviewDelegate, photos: [UIImage], selectedPhotoIndex: Int) {
        
        self.previewDelegate = delegate
        self.allPhotos = photos
        self.currentPhotoIndex = selectedPhotoIndex
        
        configureScrollView()
        configureContentView()
        configureBackButton()
        setupImageViews()
    }
    
    public override func viewDidLoad() {

        scrollView.delegate = self
        
        view.backgroundColor = UIColor.black
        //colorButton(button: exitButton)
    }
    
    private func configureScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(backButtonTapped))
        upSwipe.direction = .up
        scrollView.addGestureRecognizer(upSwipe)
    }
    
    private func configureContentView() {
        contentView = UIView()
        self.scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let screenWidth = UIScreen.main.bounds.width
        let widthValue: CGFloat = CGFloat(allPhotos.count) * screenWidth
        contentView.topAnchor.constraint(equalTo: contentView.superview!.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: contentView.superview!.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: contentView.superview!.trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: contentView.superview!.leadingAnchor).isActive = true
        contentView.heightAnchor.constraint(equalTo: contentView.superview!.heightAnchor).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: widthValue).isActive = true
    }
    
    
    private func setupImageViews(){
        
        // create all image views
        var previousView: UIView = contentView
        for x in 0...allPhotos.count-1 {
            
            let photo = allPhotos[x]
            
            // create sub scrollview
            let subScrollView = UIScrollView()
            subScrollView.delegate = self
            contentView.addSubview(subScrollView)
            allPhotoScrollViews.append(subScrollView)
            
            // create imageview
            let imageView = UIImageView(image: photo)
            imageView.contentMode = .scaleAspectFill
            subScrollView.addSubview(imageView)
            
            // add subScrollView constraints
            subScrollView.translatesAutoresizingMaskIntoConstraints = false
            let attribute: NSLayoutConstraint.Attribute = (x == 0) ? .leading : .trailing
            scrollView.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .leading, relatedBy: .equal, toItem: previousView, attribute: attribute, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: subScrollView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0))
            
            // add imageview constraints
            imageView.translatesAutoresizingMaskIntoConstraints = false
            subScrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: (photo.size.width / photo.size.height), constant: 0))
            subScrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: subScrollView, attribute: .centerX, multiplier: 1, constant: 0))
            subScrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: subScrollView, attribute: .centerY, multiplier: 1, constant: 0))
            
            // add imageview side constraints
            for attribute: NSLayoutConstraint.Attribute in [.top, .bottom, .leading, .trailing] {
                let constraintLowPriority = NSLayoutConstraint(item: imageView, attribute: attribute, relatedBy: .equal, toItem: subScrollView, attribute: attribute, multiplier: 1, constant: 0)
                let constraintGreaterThan = NSLayoutConstraint(item: imageView, attribute: attribute, relatedBy: .greaterThanOrEqual, toItem: subScrollView, attribute: attribute, multiplier: 1, constant: 0)
                constraintLowPriority.priority = UILayoutPriority(rawValue: 750)
                subScrollView.addConstraints([constraintLowPriority,constraintGreaterThan])
            }
            
            // set as previous
            previousView = subScrollView
        }
        let xOffset = CGFloat(currentPhotoIndex) * scrollView.frame.size.width
        scrollView.contentOffset = CGPoint(x: xOffset, y: 0)
    }
    
    private func configureBackButton() {
        exitButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44.0, height: 44.0))
        let image = UIImage(named: "CrossIcon")?.withRenderingMode(.alwaysTemplate)
        exitButton.setImage(image, for: .normal)
        exitButton.tintColor = .white
        exitButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.scrollView.addSubview(exitButton)
        
        exitButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        exitButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15.0).isActive = true
        exitButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10.0).isActive = true
    }
    
    // ensure scroll view has correct content size when the view size changes
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.widthAnchor.constraint(equalToConstant: CGFloat(allPhotos.count) * scrollView.frame.size.width)
        if !scrollViewDragging {
            scrollView.contentOffset = CGPoint(x: CGFloat(currentPhotoIndex) * scrollView.frame.size.width, y: 0)
        }
    }
    
    private func colorButton(button: UIButton) {
        guard let btn = button.backgroundImage(for: .normal) else { return }
        let tintableImage = btn.withRenderingMode(.alwaysTemplate)
        button.setBackgroundImage(tintableImage, for: .normal)
        button.tintColor = UIColor.white
    }
    
    private func getCurrentPageIndex() -> Int {
        return Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    }
    
    @objc func backButtonTapped() {
        previewDelegate?.updateSelectedIndex(newIndex: currentPhotoIndex)
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoPreviewController: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            scrollViewDragging = true
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            scrollViewDragging = false
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView && scrollViewDragging {
            currentPhotoIndex = getCurrentPageIndex()
        }
    }
}

extension PhotoPreviewController: ImageTransitionProtocol {
    
    public func tranisitionSetup() {
        scrollView.isHidden = true
    }
    
    public func tranisitionCleanup() {
        scrollView.isHidden = false
        let xOffset = CGFloat(currentPhotoIndex) * scrollView.frame.size.width
        scrollView.contentOffset = CGPoint(x: xOffset, y: 0)
    }
    
    public func imageWindowFrame() -> CGRect {
        
        let photo = allPhotos[currentPhotoIndex]
        let scrollWindowFrame = scrollView.superview!.convert(scrollView.frame, to: nil)
        
        let scrollViewRatio = scrollView.frame.size.width / scrollView.frame.size.height
        let imageRatio = photo.size.width / photo.size.height
        let touchesSides = (imageRatio > scrollViewRatio)
        
        if touchesSides {
            let height = scrollWindowFrame.size.width / imageRatio
            let yPoint = scrollWindowFrame.origin.y + (scrollWindowFrame.size.height - height) / 2
            return CGRect(x: scrollWindowFrame.origin.x, y: yPoint, width: scrollWindowFrame.size.width, height: height)
        } else {
            let width = scrollWindowFrame.size.height * imageRatio
            let xPoint = scrollWindowFrame.origin.x + (scrollWindowFrame.size.width - width) / 2
            return CGRect(x: xPoint, y: scrollWindowFrame.origin.y, width: width, height: scrollWindowFrame.size.height)
        }
    }
}
