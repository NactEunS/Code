//
//  AppDelegate.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/15.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // 设置导航栏按钮的外观
        setupAppearance()
        
        // TODO: 加载账号,能加载到账号表示用户登录了,加载不到账号表示用户没有登录
        let userAccount = CZUserAccount.loadUserAccount()
        print("加载账号: userAccount: \(userAccount)")

        // 创建window
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // 设置window的背景颜色
        window?.backgroundColor = UIColor.whiteColor()
        
        // 创建tabbar控制器
//        let tabbarVC = CZMainViewController()
        
        // 设置root控制器
        window?.rootViewController = defaultViewController()
        
        // TODO: 测试新特性界面, 别人调用尽量简单
//        window?.rootViewController = CZWelcomeViewController()
        
        // 显示window
        // ?: 表示?前面的有值就执行?号后面的代码,
        // ?前面的为nil不执行后面的代码, 整个表达式返回nil
        window?.makeKeyAndVisible()
        
        // 测试判断新版本功能
//        let newVersion = isNewVersion()
//        print("newVersion： \(newVersion)")
        return true
    }
    
    /// 判断程序启动后显示的默认控制器
    private func defaultViewController() -> UIViewController {
        // 判断用户是否登录
        if !CZUserAccount.userLogin {
            // 用户没有登录, 返回CZMainViewController对象
            return CZMainViewController()
        }
        
        // 用户已经登录
        return isNewVersion() ? CZNewFeatureViewController() : CZWelcomeViewController()
    }
    
    // 目标控制器有2个
    // 谁来赋值切换AppDelegate,切换界面其实就是切换window的跟控制器.window是AppDelegate的一个属性,AppDelegate来负责切换最合适
    /// 切换程序的根控制器, isMain = true 表示切换到MainViewController, isMain = false 表示切换到WelcomeViewController
    private func switchRootViewController(isMain: Bool) {
        window?.rootViewController = isMain ? CZMainViewController() : CZWelcomeViewController()
    }
    
    /// 类方法,切换控制器,外部调用
    class func outSwitchRootViewController(isMain: Bool) {
        // 拿到 AppDelegate 对象
        (UIApplication.sharedApplication().delegate as! AppDelegate).switchRootViewController(isMain)
    }
    
    /// 设置导航栏按钮的外观
    private func setupAppearance() {
        let bar = UINavigationBar.appearance()
        bar.tintColor = UIColor.orangeColor()
    }
    
    /// MARK: - 判断是否是新版本
    /// 判断是否是新版本
    private func isNewVersion() -> Bool {
        // 1. 获取到当前版本
        let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        print("当前版本: \(currentVersion)")
        
        // 2. 获取上一次保存的版本
        let sandboxVersionKey = "sandboxVersionKey" // 保存到沙盒的key
        let sandboxVersion = NSUserDefaults.standardUserDefaults().stringForKey(sandboxVersionKey)
        print("沙盒版本: \(sandboxVersion)")
        
        // 3.判断是否是新版
        let newVersion = currentVersion != sandboxVersion
        
        if newVersion {
            // 4. 保存当前版本
            NSUserDefaults.standardUserDefaults().setObject(currentVersion, forKey: sandboxVersionKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // 5. 返回
        return newVersion
    }
}

