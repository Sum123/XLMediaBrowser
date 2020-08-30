//
//  XLMediaBrowserTransition.swift
//  mediaBrowser
//
//  Created by 夏磊 on 2020/8/25.
//  Copyright © 2020 sum123. All rights reserved.
//

import UIKit

class MediaBrowserTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var type: MediaBrowserTransitionType = .present
    var media: Media = Media()
    
    public init(with type: MediaBrowserTransitionType, media: Media) {
        self.type = type
        self.media = media
        super.init()
    }
    
    private override init() {}
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch type {
        case .present:
            presentAnimation(transitionContext: transitionContext)
        case .dismiss:
            dismissAnimation(transitionContext: transitionContext)
        }
    }
    
    func presentAnimation(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView
        toView.isHidden = true
        toView.clipsToBounds = true
        containerView.addSubview(toView)
        
        let bgView = UIView()
        bgView.frame = containerView.bounds
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0
        containerView.addSubview(bgView)
        
        if media.type == .img {
            let animationView = UIImageView()
            animationView.contentMode = .scaleAspectFill
            animationView.clipsToBounds = true
            animationView.sd_setImage(with: URL(string: media.lowUrl))
            animationView.frame = media.sourceFrame
            animationView.layer.cornerRadius = MediaBrowserManager.shared.environment.cornerRadius
            animationView.backgroundColor = MediaBrowserManager.shared.environment.contentViewBgColor
            containerView.addSubview(animationView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                bgView.alpha = 1
                animationView.frame = self.media.endFrame
                animationView.layer.cornerRadius = 0
            }) { (_) in
                toView.isHidden = false
                bgView.removeFromSuperview()
                animationView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
        
        else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                bgView.alpha = 1
            }) { (_) in
                toView.isHidden = false
                bgView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
    
    func dismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(true)
            return
        }
        
        fromVC.view.isHidden = true
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        let bgView = UIView()
        bgView.frame = containerView.bounds
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 1
        containerView.addSubview(bgView)
        
        if media.type == .img {
            let animationView = UIImageView()
            animationView.contentMode = .scaleAspectFill
            animationView.clipsToBounds = true
            animationView.sd_setImage(with: URL(string: media.lowUrl))
            animationView.frame = media.endFrame
            animationView.backgroundColor = MediaBrowserManager.shared.environment.contentViewBgColor
            containerView.addSubview(animationView)
            
            var intersect: Bool = true
            if media.sourceFrame.width == 0 || media.sourceFrame.height == 0 || !UIScreen.main.bounds.intersects(self.media.sourceFrame) {
                intersect = false
            }
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                bgView.alpha = 0
                animationView.layer.cornerRadius = MediaBrowserManager.shared.environment.cornerRadius
                if intersect {
                    animationView.frame = self.media.sourceFrame
                }else {
                    animationView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    animationView.alpha = 0
                }
            }) { (_) in
                bgView.removeFromSuperview()
                animationView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
        else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                bgView.alpha = 0
            }) { (_) in
                bgView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
        
        
    }
}
