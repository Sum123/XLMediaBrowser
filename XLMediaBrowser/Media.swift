//
//  XLMedia.swift
//  mediaBrowser
//
//  Created by 夏磊 on 2020/8/24.
//  Copyright © 2020 sum123. All rights reserved.
//

import UIKit
import SDWebImage

public class Media: NSObject {
    
    /// 媒体类型
    public var type: MediaType = .img
    
    /// 低质量的url
    public var lowUrl: String = "" {
        didSet {
            let wh = min(screenW, screenH)
            endFrame = CGRect(x: (screenW - wh) * 0.5, y: (screenH - wh) * 0.5, width: wh, height: wh)
            
            if lowUrl.count > 0 {
                if let img: UIImage = SDImageCache.shared.imageFromCache(forKey: lowUrl) {
                    lowImage = img
                }else {
                    SDWebImageManager.shared.loadImage(with: URL(string: lowUrl), options: .lowPriority, progress: nil) { [weak self] (img, _, _, _, _, _) in
                        if let img: UIImage = img {
                            self?.lowImage = img
                        }else {
                            let wh = min(screenW, screenH)
                            self?.endFrame = CGRect(x: (screenW - wh) * 0.5, y: (screenH - wh) * 0.5, width: wh, height: wh)
                        }
                    }
                }
            }
        }
    }
    
    /// 低质量的image
    public var lowImage: UIImage? = nil {
        didSet {
            guard let img = lowImage else { return }
            
            if screenH > screenW {
                let w: CGFloat = screenW
                let h: CGFloat = w * img.size.height / img.size.width
                if h >= screenH {
                    endFrame = CGRect(x: 0, y: 0, width: w, height: h)
                }else {
                    endFrame = CGRect(x: 0, y: (screenH - h) * 0.5, width: w, height: h)
                }
            }else {
                let h: CGFloat = screenH
                let w: CGFloat = h * img.size.width / img.size.height
                if w >= screenW {
                    endFrame = CGRect(x: 0, y: 0, width: screenW, height: h)
                }else {
                    endFrame = CGRect(x: (screenW - w) * 0.5, y: 0, width: w, height: h)
                }
            }
            
        }
    }
    
    /// 高质量的url
    public var highUrl: String = ""
    
    /// 高质量的image
    public var highImage: UIImage? = nil
    
    /// 媒体宽 服务器数据
    public var mediaW: CGFloat = 100
    
    /// 媒体高 服务器数据
    public var mediaH: CGFloat = 100
    
    /// 来源视图中的view相对于window的frame
    public var sourceFrame: CGRect = .zero
    
    /// 最终视图中的view相对于window的frame
    public var endFrame: CGRect = .zero
    
}
