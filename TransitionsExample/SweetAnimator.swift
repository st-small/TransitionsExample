//
//  SweetAnimator.swift
//  TransitionsExample
//
//  Created by Stanly Shiyanovskiy on 4/19/19.
//  Copyright © 2019 Stanly Shiyanovskiy. All rights reserved.
//

import UIKit

public protocol ImageTransitionProtocol {
    func tranisitionSetup()
    func tranisitionCleanup()
    func imageWindowFrame() -> CGRect
}

public class SweetAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var image: UIImage?
    private var fromDelegate: ImageTransitionProtocol?
    private var toDelegate: ImageTransitionProtocol?
    
    public func setupImageTransition(image: UIImage, fromDelegate: ImageTransitionProtocol, toDelegate: ImageTransitionProtocol) {
        self.image = image
        self.fromDelegate = fromDelegate
        self.toDelegate = toDelegate
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        
        toVC.view.frame = fromVC.view.frame
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = (fromDelegate == nil) ? CGRect.zero : fromDelegate!.imageWindowFrame()
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)
        
        fromDelegate!.tranisitionSetup()
        toDelegate!.tranisitionSetup()
        
        guard let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true) else { return }
        fromSnapshot.frame = fromVC.view.frame
        containerView.addSubview(fromSnapshot)
        
        guard let toSnapshot = toVC.view.snapshotView(afterScreenUpdates: true) else { return }
        toSnapshot.frame = fromVC.view.frame
        containerView.addSubview(toSnapshot)
        toSnapshot.alpha = 0
        
        containerView.bringSubviewToFront(imageView)
        let toFrame = (self.toDelegate == nil) ? CGRect.zero : self.toDelegate!.imageWindowFrame()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            toSnapshot.alpha = 1
            imageView.frame = toFrame
            
        }, completion:{ [weak self] (finished) in
            
            self?.toDelegate!.tranisitionCleanup()
            self?.fromDelegate!.tranisitionCleanup()
            
            imageView.removeFromSuperview()
            fromSnapshot.removeFromSuperview()
            toSnapshot.removeFromSuperview()
            
            if !transitionContext.transitionWasCancelled {
                containerView.addSubview(toVC.view)
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
