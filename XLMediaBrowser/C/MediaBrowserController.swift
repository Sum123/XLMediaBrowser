//
//  XLMediaBrowserController.swift
//  mediaBrowser
//
//  Created by 夏磊 on 2020/8/24.
//  Copyright © 2020 sum123. All rights reserved.
//

import UIKit

class MediaBrowserController: UIViewController {
    
    // MARK: - Property
    let cellId = "XLMediaBrowserCellID"
    
    lazy var env: Environment = MediaBrowserManager.shared.environment
    
    lazy var interactive = MediaBrowserInteractive()
    
    //    let space: CGFloat = 20
    
    // MARK: - Life Cycle
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        if env.pageNumeType == .round {
            if #available(iOS 11.0, *) {
                pageControl.center = CGPoint(x: view.bounds.width * 0.5, y: view.bounds.height - view.safeAreaInsets.bottom - 10 - pageControl.bounds.height)
            } else {
                pageControl.center = CGPoint(x: view.bounds.width * 0.5, y: view.bounds.height - 10 - pageControl.bounds.height)
            }
        }else {
            pageLabel.bounds.size = CGSize(width: view.bounds.width - 20, height: 20)
            if #available(iOS 11.0, *) {
                pageLabel.center = CGPoint(x: view.bounds.width * 0.5, y: view.bounds.height - view.safeAreaInsets.bottom - 10 - pageLabel.bounds.height)
            } else {
                pageLabel.center = CGPoint(x: view.bounds.width * 0.5, y: view.bounds.height - 10 - pageLabel.bounds.height)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Method
    private func setupData() {
        collectionView.reloadData()
        view.layoutIfNeeded()
        
        if env.chooseIndex < env.mediaArr.count {
            let idxPath: IndexPath = IndexPath(item: env.chooseIndex, section: 0)
            collectionView.scrollToItem(at: idxPath, at: .left, animated: false)
        }
    }
    
    private func currentMedia(with present: Bool) -> Media {
        var index: NSInteger = 0
        if present {
            index = env.chooseIndex
        }else {
            index = NSInteger(collectionView.contentOffset.x / collectionView.bounds.width + 0.5)
        }
        
        if index < 0 {
            return env.mediaArr.first!
        }else if index > env.mediaArr.count {
            return env.mediaArr.last!
        }else {
            return env.mediaArr[index]
        }
    }
    
    // MARK: - UI
    private func setupUI() {
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        if env.pageNumeType == .round {
            view.addSubview(pageControl)
        }else {
            view.addSubview(pageLabel)
        }
    }
    
    // MARK: - Lazy
    private lazy var layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 0
        l.minimumInteritemSpacing = 0
        l.scrollDirection = .horizontal
        
        return l
    }()
    
    private lazy var collectionView: UICollectionView = {
        let v = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), collectionViewLayout: layout)
        if #available(iOS 11.0, *) {
            v.contentInsetAdjustmentBehavior = .never
        }
        v.backgroundColor = UIColor.clear
        v.showsHorizontalScrollIndicator = false
        v.showsVerticalScrollIndicator = false
        v.dataSource = self
        v.delegate = self
        v .register(MediaBrowserCell.self, forCellWithReuseIdentifier: cellId)
        v.isPagingEnabled = true
        return v
    }()
    
    lazy var pageControl: UIPageControl = {
        let v = UIPageControl()
        v.hidesForSinglePage = true
        v.numberOfPages = self.env.mediaArr.count
        v.currentPage = self.env.chooseIndex
        return v
    }()
    
    lazy var pageLabel: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.white
        v.font = UIFont.systemFont(ofSize: 14)
        v.textAlignment = .center
        v.text = "\(self.env.chooseIndex+1) / \(self.env.mediaArr.count)"
        v.backgroundColor = UIColor.clear
        return v
    }()
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MediaBrowserController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return env.mediaArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MediaBrowserCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MediaBrowserCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item < env.mediaArr.count {
            
            guard let browserCell: MediaBrowserCell = cell as? MediaBrowserCell else { return }
            browserCell.delegate = self
            browserCell.bind(with: env.mediaArr[indexPath.item])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let index: NSInteger = max(0, min(NSInteger(scrollView.contentOffset.x / scrollView.bounds.width + 0.5), env.mediaArr.count-1))
            
            if env.pageNumeType == .round {
                pageControl.currentPage = index
            }else {
                pageLabel.text = "\(index+1) / \(env.mediaArr.count)"
            }
        }
    }
}

// MARK: - XLMediaBrowserCellDelegate
extension MediaBrowserController: MediaBrowserCellDelegate {
    func mediaBrowserCell(_ cell: MediaBrowserCell, pan: UIPanGestureRecognizer, media: Media?) {
        interactive.panAction(pan, media: media, vc: self)
    }
    
    func mediaBrowserCell(_ cell: MediaBrowserCell, singleTap media: Media?) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension MediaBrowserController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MediaBrowserTransition(with: .present, media: currentMedia(with: true))
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MediaBrowserTransition(with: .dismiss, media: currentMedia(with: false))
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactive.interation ? interactive : nil
    }
}
