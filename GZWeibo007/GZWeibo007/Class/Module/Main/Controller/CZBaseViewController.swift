//
//  CZBaseViewController.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/15.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

class CZBaseViewController: UITableViewController, CZVisitorViewDelegate {
    
    /// 用户是否登录
    var userLogin = CZUserAccount.userLogin
    
    override func loadView() {
        userLogin ? super.loadView() : setupVistorView()
    }
    
    /// 设置访客视图
    func setupVistorView() {
        // 设置一个view
        view = visitorView
        
        // 设置代理, 
        // 当对象没有实现协议,会报错
        // 实现协议后还会报错,需要实现协议里面的方法
        visitorView.delegate = self
        
        // 设置导航栏按钮
        // 左边
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.Plain, target: self, action: "visitorViewRegisterClick")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登陆", style: UIBarButtonItemStyle.Plain, target: self, action: "visitorViewLoginClick")
        
        // 根据不同控制器设置不同内容
        // 设置访客视图内容
        print("当前控制器: \(self)")
        if self is CZHomeViewController {
            // 设置动画
            visitorView.startRotationAnimation()
            
            // 程序退到后台会进入前台都会发送通知.
            // 注册通知
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
            
        } else if self is CZMessageViewController {
            visitorView.setupVisitorInfo("visitordiscover_image_message", message: "登录后，别人评论你的微博，发给你的消息，都会在这里收到通知")
        } else if self is CZDiscoveryViewController {
            visitorView.setupVisitorInfo("visitordiscover_image_message", message: "登录后，最新、最热微博尽在掌握，不再会与实事潮流擦肩而过")
        } else if self is CZProfileViewController {
            visitorView.setupVisitorInfo("visitordiscover_image_profile", message: "登录后，你的微博、相册、个人资料会显示在这里，展示给别人")
        }
    }
    
    // 析构函数,对象销毁的时候调用
    deinit {
        // 首页移除通知
        if self is CZHomeViewController {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    /// 登陆按钮点击事件
    func visitorViewLoginClick() {
        // 创建登陆界面
        let oauthVC = CZOauthViewController()
        
        // 弹出登陆界面,包装导航控制器
        presentViewController(UINavigationController(rootViewController: oauthVC), animated: true, completion: nil)
    }
    
    /// 注册按钮点击事件
    func visitorViewRegisterClick() {
        print(__FUNCTION__)
    }
    
    // MARK: - 通知
    // 退到后台
    func didEnterBackground() {
        // 停止转轮旋转
        // __FUNCTION__: 将方法名称打印出来
        print(__FUNCTION__)
        visitorView.pauseAnimation()
    }
    
    // 进入前台
    func didBecomeActive() {
        // 恢复转轮旋转
        print(__FUNCTION__)
        visitorView.resumeAnimation()
    }
    
    // 懒加载 访客视图
    lazy var visitorView: CZVistorView = CZVistorView()
}
