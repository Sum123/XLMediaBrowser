//
//  XLMediaBrowserManager.swift
//  mediaBrowser
//
//  Created by 夏磊 on 2020/8/24.
//  Copyright © 2020 sum123. All rights reserved.
//

import UIKit

public class MediaBrowserManager: NSObject {
    
    public static let shared = MediaBrowserManager()
    private override init() {}
    
    lazy var environment: Environment = Environment()

    public func showMedia(mediaArr: [Media], chooseIndex: NSInteger, vc: UIViewController, pageNumType: PageNumType = .round, cornerRadius: CGFloat = 0) {
        
        assert(mediaArr.count > 0, "You did not add medias")
        
        let env = Environment()
        env.mediaArr = mediaArr
        env.chooseIndex = chooseIndex
        env.vc = vc
        env.pageNumeType = pageNumType
        env.cornerRadius = cornerRadius
        
        showMedia(environment: env)
    }
    
    func showMedia(environment: Environment) {
        self.environment = environment
        let browserVC = MediaBrowserController()
        environment.vc?.present(browserVC, animated: true, completion: nil)
    }

}
