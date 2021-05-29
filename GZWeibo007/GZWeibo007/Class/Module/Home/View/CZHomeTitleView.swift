//
//  CZHomeTitleView.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/20.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

class CZHomeTitleView: UIButton {
    
    /**
     创建首页导航栏标题按钮
     
     - parameter imageName: 按钮图片的名称
     - parameter title:     按钮的标题
     
     - returns: 按钮
     */
    init(imageName: String, title: String) {
        super.init(frame: CGRectZero)
        setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        setTitle(title, forState: UIControlState.Normal)
        setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 修改图片和文字的布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 1. 将文字的origin.x设置为0
        // OC中
//        var frame = self.titleLabel.frame
//        frame.origin.x = 0
//        self.titleLabel.frame = frame
        // ! 和 ? 都行的情况下,建议加?
        self.titleLabel?.frame.origin.x = 0
        
        // 2. 将图片的origin.x设置为文字的宽度
        // self.titleLabel?frame.width, 有可能有值,有可能没有值,返回的是可选类型
        // self.imageView?.frame.origin.x: x是一个CGFloat类型,不接受nil
        self.imageView?.frame.origin.x = self.titleLabel!.frame.width + 3
    }

}
