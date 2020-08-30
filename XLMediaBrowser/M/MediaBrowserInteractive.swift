//
//  MediaBrowserInteractive.swift
//  mediaBrowser
//
//  Created by Sum123 on 2020/8/30.
//  Copyright © 2020 sum123. All rights reserved.
//

import UIKit

class MediaBrowserInteractive: UIPercentDrivenInteractiveTransition {
    /// 是否在交互
    var interation = false
    
    /// 记录pan手势开始时imageView的位置
    var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    var beganTouch = CGPoint.zero
    
    var xRate: CGFloat = 0
    var yRate: CGFloat = 0
    var scale: CGFloat = 0
    
    var bgView: UIView?
    var animationImgView: UIImageView?
    
    
    let dur: TimeInterval = 0.25
    
    var media: Media?
    var context: UIViewControllerContextTransitioning?
    weak var vc: MediaBrowserController?
    
    
    public func panAction(_ pan: UIPanGestureRecognizer, media: Media?, vc: MediaBrowserController) {
        self.vc = vc;
        self.media = media
        
        switch pan.state {
        case .began:
            panBegan(pan)
        case .changed:
            panChanged(pan)
        case .ended:
            panEnd(pan)
        default:
            cancelInteractive()
            break
        }
    }
    
    func panBegan(_ pan: UIPanGestureRecognizer) {
        if media != nil {
            beganTouch = pan.location(in: pan.view)
            interation = true
            vc?.dismiss(animated: true, completion: nil)
        }
    }
    
    func panChanged(_ pan: UIPanGestureRecognizer) {
        if interation {
            // 拖动偏移量
            let translation = pan.translation(in: pan.view)
            let currentTouch = pan.location(in: pan.view)
            
            scale = min(1.0, max(0, 1 - translation.y / pan.view!.bounds.height))
            update(1-scale)
            
            // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
            let newScale = max(0.3, scale)
            
            let width = beganFrame.size.width * newScale
            let height = beganFrame.size.height * newScale
            
            let currentTouchDeltaX = xRate * width
            let x = currentTouch.x - currentTouchDeltaX
            
            let currentTouchDeltaY = yRate * height
            let y = currentTouch.y - currentTouchDeltaY
            
            animationImgView?.frame = CGRect(x: x, y: y, width: width, height: height)
            bgView?.alpha = newScale
            print(scale)
        }
    }
    
    func panEnd(_ pan: UIPanGestureRecognizer) {
        let velocity = pan.velocity(in: pan.view).y
        if velocity > 800 {
            finishInteractive()
        }
        else if velocity < -600 {
            cancelInteractive()
        }
        else {
            if scale > 0.7 {
                cancelInteractive()
            }else {
                finishInteractive()
            }
        }
    }
    
    func finishInteractive() {
        if interation {
            interation = false
            finish()
            guard let context = self.context else { return }
            
            var intersect: Bool = true
            if media!.sourceFrame.width == 0 || media!.sourceFrame.height == 0 || !UIScreen.main.bounds.intersects(media!.sourceFrame) {
                intersect = false
            }
            
            UIView.animate(withDuration: dur, animations: {
                self.bgView?.alpha = 0
                self.animationImgView?.layer.cornerRadius = MediaBrowserManager.shared.environment.cornerRadius
                if intersect {
                    self.animationImgView?.frame = self.media!.sourceFrame
                }else {
                    self.animationImgView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    self.animationImgView?.alpha = 0
                }
            }) { (_) in
                self.bgView?.removeFromSuperview()
                self.animationImgView?.removeFromSuperview()
                context.completeTransition(!context.transitionWasCancelled)
            }
        }
    }
    
    func cancelInteractive() {
        if interation {
            interation = false
            cancel()
            guard let context = self.context, let fromVC = context.viewController(forKey: .from) else { return }
            fromVC.view.isHidden = true
            context.containerView.addSubview(fromVC.view)
            
            UIView.animate(withDuration: dur, animations: {
                self.bgView?.alpha = 1
                self.animationImgView?.frame = self.media!.endFrame
            }) { (_) in
                fromVC.view.isHidden = false
                self.bgView?.removeFromSuperview()
                self.animationImgView?.removeFromSuperview()
                context.completeTransition(!context.transitionWasCancelled)
            }
        }
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) else { return }
        
        self.context = transitionContext
        let containerView = transitionContext.containerView
        
        fromVC.view.isHidden = true
        containerView.addSubview(toVC.view)
        
        bgView = UIView()
        bgView!.backgroundColor = UIColor.black
        bgView!.frame = containerView.bounds
        bgView!.alpha = 1
        containerView.addSubview(bgView!)
        
        animationImgView = UIImageView()
        animationImgView!.backgroundColor = MediaBrowserManager.shared.environment.contentViewBgColor
        animationImgView!.contentMode = .scaleAspectFill
        animationImgView!.clipsToBounds = true
        animationImgView!.frame = media!.endFrame
        animationImgView!.image = media!.lowImage
        containerView.addSubview(animationImgView!)
        
        beganFrame = animationImgView!.frame
        xRate = (beganTouch.x - beganFrame.origin.x) / beganFrame.size.width
        yRate = (beganTouch.y - beganFrame.origin.y) / beganFrame.size.height
        
    }
}
