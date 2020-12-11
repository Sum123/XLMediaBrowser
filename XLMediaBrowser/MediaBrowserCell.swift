//
//  XLMediaBrowserCell.swift
//  mediaBrowser
//
//  Created by 夏磊 on 2020/8/24.
//  Copyright © 2020 sum123. All rights reserved.
//

import UIKit
import SDWebImage

protocol MediaBrowserCellDelegate: NSObject {
    func mediaBrowserCell(_ cell: MediaBrowserCell, singleTap media: Media?)
    func mediaBrowserCell(_ cell: MediaBrowserCell, pan: UIPanGestureRecognizer, media: Media?)
}

class MediaBrowserCell: UICollectionViewCell {
    
    // MARK: - Property
    weak var delegate: MediaBrowserCellDelegate?
    
    var media: Media?
    
    let minScale: CGFloat = 1
    let maxScale: CGFloat = 4
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.clear
        backgroundView?.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        contentView.addSubview(scrollView)
        scrollView.addSubview(mediaContentV)
        
        // 长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        contentView.addGestureRecognizer(longPress)
        
        // 双击手势
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
        
        // 单击手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction))
        contentView.addGestureRecognizer(singleTap)
        singleTap.require(toFail: doubleTap)
        
        // 拖动手势
        scrollView.addGestureRecognizer(panGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action
    @objc func singleTapAction() {
        delegate?.mediaBrowserCell(self, singleTap: media)
    }
    
    @objc func doubleTapAction(_ doubleTap: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        }else {
            let touchPoint = doubleTap.location(in: doubleTap.view)
            let xSize = scrollView.bounds.size.width / maxScale
            let ySize = scrollView.bounds.size.height / maxScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - xSize*0.5, y: touchPoint.y - ySize*0.5, width: xSize, height: ySize), animated: true)
        }
    }
    
    @objc func panAction(_ pan: UIPanGestureRecognizer) {
        delegate?.mediaBrowserCell(self, pan: pan, media: media)
    }
    
    @objc func longPressAction(_ pan: UILongPressGestureRecognizer) {
    }
    
    // MARK: - Method
    public func bind(with media: Media) {
        self.media = media
        
        layoutIfNeeded()
        scrollView.setZoomScale(minScale, animated: false)
        scrollView.contentSize = scrollView.bounds.size
        
        setupImageRect(nil)
        mediaContentV.bind(with: media) { [weak self] (image) in
            self?.setupImageRect(image)
        }
    }
    
    func setupImageRect(_ img: UIImage?) {
        
        guard let mediaData = self.media else {
            return
        }
        
        var imgW: CGFloat = mediaData.mediaW
        var imgH: CGFloat = mediaData.mediaH
        
        if let img = img {
            imgW = img.size.width
            imgH = img.size.height
        }else {
            scrollView.setZoomScale(minScale, animated: false)
        }
        
        if screenH > screenW {
            mediaContentV.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.width * imgH / imgW)
        }else {
            mediaContentV.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.height * imgW / imgH, height: scrollView.bounds.height)
        }
        
        checkImageContentSize()
        scrollViewDidZoom(scrollView)
    }
    
    func checkImageContentSize() {
        
        var h = scrollView.bounds.height
        var w = scrollView.bounds.width
        
        if mediaContentV.bounds.height > scrollView.bounds.height {
            h = mediaContentV.bounds.height
        }
        
        if  mediaContentV.bounds.width > scrollView.bounds.width {
            w = mediaContentV.bounds.width
        }
        scrollView.contentSize = CGSize(width: w, height: h)
    }
    
    // MARK: - Lazy
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = UIColor.clear
        v.maximumZoomScale = maxScale
        v.minimumZoomScale = minScale
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
//        v.decelerationRate = UIScrollView.DecelerationRate.fast
        v.delegate = self
        v.isMultipleTouchEnabled = true
        v.scrollsToTop = false
        v.delaysContentTouches = false
        v.canCancelContentTouches = true
        v.bouncesZoom = true
        if #available(iOS 11.0, *) {
            v.contentInsetAdjustmentBehavior = .never
        }
        return v
    }()
    
    public lazy var mediaContentV: MeidaContentView = {
        let v = MeidaContentView()
        return v
    }()
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let p = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        p.maximumNumberOfTouches = 1
        p.delegate = self
        return p
    }()
}

extension MediaBrowserCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mediaContentV
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX: CGFloat = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0
        
        let offsetY: CGFloat = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0
        
        mediaContentV.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}

extension MediaBrowserCell: UIGestureRecognizerDelegate {
    
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 放大时不相应手势
        if scrollView.zoomScale > minScale {
            return false
        }
        
        // 只响应pan手势
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer, pan == panGesture else {
            return true
        }
        
        let velocity = pan.velocity(in: self)
        // 向上滑动时，不响应手势
        if velocity.y < 0 {
            return false
        }
        
        // 横向滑动时，不响应pan手势
        if abs(Int(velocity.x)) > Int(velocity.y) {
            return false
        }
        
        // 向下滑动，如果图片顶部超出可视区域，不响应手势
        if scrollView.contentOffset.y > 0 {
            return false
        }
        return true
    }
}


