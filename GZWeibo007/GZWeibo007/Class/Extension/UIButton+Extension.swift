//
//  UIButton+Extension.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/21.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

extension UIButton {
    
    /**
     按钮便利构造函数
     
     - parameter imageName: 按钮图片名称
     - parameter fontSize:  按钮文字大小
     - parameter title:     按钮文字
     
     - returns: 按钮
     */
    convenience init(imageName: String, fontSize: CGFloat, title: String) {
        self.init()
        
        // 设置图片
        setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        
        // 设置文字颜色
        setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        
        // 设置文字大小
        titleLabel?.font = UIFont.systemFontOfSize(fontSize)
        
        // 设置文字的内容
        setTitle(title, forState: UIControlState.Normal)
    }
}