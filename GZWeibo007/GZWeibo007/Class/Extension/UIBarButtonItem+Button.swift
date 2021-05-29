//
//  UIBarButtonItem+Button.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/20.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

// 扩展UIBarButtonItem
extension UIBarButtonItem {
    
    /**
    便利构造函数,创建UIBarButtonIten
    
    - parameter imageName: 图片的正常状态的名称
    
    - returns: UIBarButtonItem
    */
    convenience init(imageName: String) {   // 在扩展里面只能是便利构造函数
        let highlightedImageName = imageName + "_highlighted"
        // 右边按钮
        let button = UIButton()
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        button.setImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
        
        // 自己根据图片的大小来适应
        button.sizeToFit()
        
        // 便利构造函数需要调用一个当前类的指定构造函数
        self.init(customView: button)
    }
    
    /// 创建UIBarButtonItem按钮(2张图片)
    class func createBarButtonItem(imageName: String) -> UIBarButtonItem {
        let highlightedImageName = imageName + "_highlighted"
        // 右边按钮
        let button = UIButton()
        button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        button.setImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
        
        // 自己根据图片的大小来适应
        button.sizeToFit()
        
        // 导航栏右边
        return UIBarButtonItem(customView: button)
    }
}
