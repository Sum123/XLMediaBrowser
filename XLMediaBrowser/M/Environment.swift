//
//  XLEnvironment.swift
//  mediaBrowser
//
//  Created by 夏磊 on 2020/8/24.
//  Copyright © 2020 sum123. All rights reserved.
//

import UIKit

var screenW: CGFloat {
    return UIScreen.main.bounds.width
}

var screenH: CGFloat {
    return UIScreen.main.bounds.height
}

enum MediaBrowserTransitionType {
    case present
    case dismiss
}

enum MediaType {
    case img
    case video
}

enum PageNumType {
    case round
    case label
}

public class Environment: NSObject {
    var mediaArr: [Media] = []
    var chooseIndex: NSInteger = 0
    weak var vc: UIViewController?
    var pageNumeType: PageNumType = .round
    var cornerRadius: CGFloat = 0
    var contentViewBgColor: UIColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
}

