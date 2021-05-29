
//
//  UILabel+Extension.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/21.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

extension UILabel {
    
    convenience init(color: UIColor, fontSize: CGFloat) {
        self.init()
        
        // 设置字体颜色
        textColor = color
        
        // 设置大小
        font = UIFont.systemFontOfSize(fontSize)
    }
}
