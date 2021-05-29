//
//  CZMainViewController.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/15.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

class CZMainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 自定义tabbar,是只读的,不能直接使用 = 进行赋值
        // KVC 进行替换
        let mainTabBar = CZMainTabbar()
        setValue(mainTabBar, forKey: "tabBar")
        
        // 设置tabbar的tintColor
//        self.tabBar.tintColor = UIColor.orangeColor()

        // 首页
        let homeVC = CZHomeViewController()
        self.addChildVC(homeVC, title: "首页", imageName: "tabbar_home")

        // 消息
        let messageVC = CZMessageViewController()
        self.addChildVC(messageVC, title: "消息", imageName: "tabbar_message_center")
        
        // 发现
        let discoveryVC = CZDiscoveryViewController()
        self.addChildVC(discoveryVC, title: "发现", imageName: "tabbar_discover")
        
        // 我
        let profileVC = CZProfileViewController()
        self.addChildVC(profileVC, title: "我", imageName: "tabbar_profile")
    }
    
    /// controller: 控制器
    /// title: 控制器显示的标题
    /// imageName: 在tabbar上面显示的图片名称
    private func addChildVC(controller: UIViewController, title: String, imageName: String) {
        // 包装导航控制器
        self.addChildViewController(UINavigationController(rootViewController: controller))
        
        // 设置title,导航栏和tabBar上都有
        controller.title = title
        
        // 设置图片
        controller.tabBarItem.image = UIImage(named: imageName)
        
        // 设置高亮图片
        let highLightedName = imageName + "_highlighted"
        controller.tabBarItem.selectedImage = UIImage(named: highLightedName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        // 设置文字颜色
        // NSForegroundColorAttributeName: 设置文字的前景颜色
        controller.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.orangeColor()], forState: UIControlState.Selected)
    }
    
    // private: 方法不想让别人调用, 即可以修饰方法,也可以修饰属性
    private func old() {
        // 首页
        let homeVC = CZHomeViewController()
        // 包装导航控制器
        self.addChildViewController(UINavigationController(rootViewController: homeVC))
        // 设置title,导航栏和tabBar上都有
        homeVC.title = "首页"
        // 设置图片
        homeVC.tabBarItem.image = UIImage(named: "tabbar_home")
        
        // 消息
        let messageVC = CZHomeViewController()
        // 包装导航控制器
        self.addChildViewController(UINavigationController(rootViewController: messageVC))
        // 设置title,导航栏和tabBar上都有
        messageVC.title = "消息"
        // 设置图片
        messageVC.tabBarItem.image = UIImage(named: "tabbar_message_center")
        
        // 发现
        let discoveryVC = CZHomeViewController()
        // 包装导航控制器
        self.addChildViewController(UINavigationController(rootViewController: discoveryVC))
        // 设置title,导航栏和tabBar上都有
        discoveryVC.title = "发现"
        // 设置图片
        discoveryVC.tabBarItem.image = UIImage(named: "tabbar_discover")
        
        // 我
        let profileVC = CZHomeViewController()
        // 包装导航控制器
        self.addChildViewController(UINavigationController(rootViewController: profileVC))
        // 设置title,导航栏和tabBar上都有
        profileVC.title = "我"
        // 设置图片,不需要系统来渲染颜色
        profileVC.tabBarItem.image = UIImage(named: "tabbar_profile")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
    }
}
