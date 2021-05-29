//
//  CZMainTabbar.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/15.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

class CZMainTabbar: UITabBar {
    
    // 属性
    /// 5个子控件
    private let Count = 5

    override func layoutSubviews() {
        // 一定要记得调用父类的layoutSubviews
        super.layoutSubviews()
        
//        print("layoutSubviews--------------")
        
        // 计算UITabBarButton宽度
        let width = self.bounds.width / CGFloat(Count)
        
        // 最左边的frame
        let frame = CGRect(x: 0, y: 0, width: width, height: self.bounds.height)
        
        // 遍历所有子空间
        var index = 0
        
        for view in self.subviews {
//            print("view: \(view)")
            
            // 设置 UITabBarButton 的frame
            // UITabBarButton 继承UIContorl
            // is: 判断类型
            if view is UIControl && !(view is UIButton) {
                // 在这个方法里面只想给 UITabBarButton 设置frame,需要过滤掉 composeButton 按钮
                // 重新设置frame
                // CGRectOffset:  CGRect偏移
                view.frame = CGRectOffset(frame, CGFloat(index) * width, 0)
                
                index += index == 1 ? 2 : 1
//                index++
//                if index == 2 {
//                    index++
//                }
            }
        }
        
        // 设置加号按钮的frame
        composeButton.frame = CGRectOffset(frame, 2.0 * width, 0)
    }

    // MARK: - 懒加载
    /// 加号按钮
    lazy var composeButton: UIButton = {
        let button = UIButton()
        
        // 设置背景图片
        button.setBackgroundImage(UIImage(named: "tabbar_compose_button"), forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), forState: UIControlState.Highlighted)
        
        // 设置按钮图片
        button.setImage(UIImage(named: "tabbar_compose_icon_add"), forState: UIControlState.Normal)
        button.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), forState: UIControlState.Highlighted)
        
        // 添加到父控件上面
        // 在代码块不能省略self
        self.addSubview(button)
        
        return button
    }()
}
