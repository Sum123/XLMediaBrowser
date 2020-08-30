//
//  MeidaContentView.swift
//  mediaBrowser
//
//  Created by Sum123 on 2020/8/30.
//  Copyright © 2020 sum123. All rights reserved.
//

import UIKit
import DACircularProgress

typealias FinishBlock = (_ image: UIImage?) -> Void

class MeidaContentView: UIView {
    
    var media: Media?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        
        addSubview(imgView)
        addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.frame = bounds
        progressView.frame = CGRect(x: (bounds.width - 50) * 0.5, y: (bounds.height - 50) * 0.5, width: 50, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    public func bind(with media: Media, finish:@escaping  FinishBlock) {
        self.media = media
        
        if media.lowUrl.count > 0 {
            if let lowImage: UIImage = media.lowImage {
                
                progressView.isHidden = true
                
                imgView.image = lowImage
                finish(lowImage)
                
                if let highImage: UIImage = media.highImage {
                    imgView.image = highImage
                    finish(highImage)

                }else {
                    if media.lowUrl != media.highUrl {
                        
                        progressView.progress = 0
                        progressView.isHidden = false
                        
                        imgView.sd_setImage(with: URL(string: media.highUrl), placeholderImage: lowImage, options: .highPriority, progress: { [weak self] (receivedSize, expectedSize, _) in
                            let p: CGFloat = CGFloat(receivedSize) / CGFloat(expectedSize)
                            print("下载大图 \(p)")
                            if p > 0 {
                                DispatchQueue.main.async {
                                    self?.progressView.progress = p
                                }
                            }
                        }) { [weak self] (highImage, bigError, _, _) in

                            if let image: UIImage = highImage, let self = self {
                                self.media?.highImage = image
                                self.imgView.image = image
                                finish(image)
                            }
                            self?.progressView.isHidden = true
                        }
                    }
                }
            }
                
            else {
                progressView.progress = 0
                progressView.isHidden = false
                
                imgView.sd_setImage(with: URL(string: media.lowUrl), placeholderImage: nil, options: .highPriority, progress: { [weak self] (receivedSize, expectedSize, _) in
                    let p: CGFloat = CGFloat(receivedSize) / CGFloat(expectedSize)
                    print("下载小图 \(p)")
                    if p > 0 {
                        DispatchQueue.main.async {
                            self?.progressView.progress = p
                        }
                    }
                }) { [weak self] (lowImage, lowError, _, _) in
                    if let image: UIImage = lowImage, let self = self {
                        self.media?.lowImage = image
                        self.imgView.image = image
                        finish(image)
                    }else {
                        finish(nil)
                    }
                    self?.progressView.isHidden = true
                }
            }
        }
        
        else {
            progressView.progress = 0
            progressView.isHidden = true

            imgView.image = nil
            finish(nil)
        }
    }
    
    // MARK: - Lazy
    private lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = MediaBrowserManager.shared.environment.contentViewBgColor
        return v
    }()
    
    lazy var progressView: DACircularProgressView = {
        let v = DACircularProgressView()
        v.roundedCorners = 1
        v.trackTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        v.progressTintColor = UIColor.white
        return v
    }()
    
}
