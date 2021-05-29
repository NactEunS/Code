//
//  CZUserAccount.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/18.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

/*
    iOS数据保存方式
        1.偏好设置
        2.归档和解档(对象)
        3.NSArray/NSDictionary直接写到Plist
        4.Sqlite数据库
        5.CoreData(核心Sqlite数据库)
*/

// CustomStringConvertible
class CZUserAccount: NSObject, NSCoding {
    // 1.定义属性
    // 属性是可选的时候,可以在任何时候赋值
    
    /// 类属性,不用创建对象,直接调用,用户是否登录,计算性属性,只提供get方法
    class var userLogin: Bool {
        // 只有get方法是可以缩写
        // 能加载到账号表示用户登录了,加载不到账号表示用户没有登录
        // 有账号返回true,没有账号返回false
        return CZUserAccount.loadUserAccount() != nil
//        get {
//            return true
//        }
    }
    
    /// AccessToken
    var access_token: String?
    
    /// 当前授权用户的UID
    var uid: String?
    
    /// access_token的生命周期，单位是秒数,新浪文档上写的是String，实际上返回的是Int类型
    /// Int/Float/Double类型不能定义为可选,定义为可选KVC找不到
    // 是一个数字,不方便日期比较
    var expires_in: NSTimeInterval = 0 {
        didSet {    // 在init的调用super.init之前属性监视器不起效果
            // 自己来生成,过期时间NSDate
            expires_Date = NSDate(timeIntervalSinceNow: expires_in)
        }
    }
    
    /// 过期时间
    var expires_Date: NSDate?
    
    /// 用户昵称
    var screen_name: String?
    
    /// 用户头像地址（大图），180×180像素
    var avatar_large: String?
    
    /// 2.字典转模型
    init(dict: [String: AnyObject]) {
        // 属性不是特别多的时候可以直接单个赋值
        super.init()
        // KVC,方法必须在init后面调用
        setValuesForKeysWithDictionary(dict)
    }
    
    // 3.当字典的key在模型里面找不到属性的时候会调用
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    /// 4.打印对象内容
    override var description: String {
        get {
            return "access_token: \(access_token), uid: \(uid), expires_in: \(expires_in), expires_Date: \(expires_Date)"
        }
    }
    
    // MARK: - 加载用户数据
    func loadUserInfo(finished: (error: NSError?) -> ()) {
        // 调用网络工具类的方法来加载用户信息,准备一个闭包
        CZNetworkTool.sharedInstance.loadUserInfo { (result, error) -> () in
            // 判断是否又错误
            if error != nil || result == nil {
//                print("获取用户数据有错误: \(error)")
                finished(error: error)
                return
            }
            
            // 能到下面来表示没有错误.
            // 解析服务器返回的数据,获取用户的名称和用户的头像地址
            self.screen_name = result!["screen_name"] as? String
            self.avatar_large = result!["avatar_large"] as? String
            
            // 对象更新了内容.
            // 1.将最新的对象保存到沙盒
            self.saveUserAccount()
            
            // 2.将最新的对象(self)赋值给属性 CZUserAccount.userAccount
            // userAccount是一个类属性,需要使用类名.属性名来访问
            CZUserAccount.userAccount = self
            
            // 3.调用闭包告诉控制器获取用户数据成功了.
            finished(error: nil)
        }
    }
    
    // MARK: - 归档和接档
    /// 归档
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(access_token, forKey: "access_token")
        aCoder.encodeObject(uid, forKey: "uid")
        aCoder.encodeDouble(expires_in, forKey: "expires_in")
        aCoder.encodeObject(expires_Date, forKey: "expires_Date")
        aCoder.encodeObject(screen_name, forKey: "screen_name")
        aCoder.encodeObject(avatar_large, forKey: "avatar_large")
    }
    
    /// 解档
    required init?(coder aDecoder: NSCoder) {
        // 一定要记得赋值给属性
        access_token = aDecoder.decodeObjectForKey("access_token") as? String
        uid = aDecoder.decodeObjectForKey("uid") as? String
        expires_in = aDecoder.decodeDoubleForKey("expires_in")
        expires_Date = aDecoder.decodeObjectForKey("expires_Date") as? NSDate
        screen_name = aDecoder.decodeObjectForKey("screen_name") as? String
        avatar_large = aDecoder.decodeObjectForKey("avatar_large") as? String
    }
    
    // 1. 获取沙盒路径
    // 2. 拼接文件名
    static let path = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! as NSString).stringByAppendingPathComponent("userAccount.plist")
    
    // 使用归档和接档
    /// 保存账户信息
    func saveUserAccount() {
        // rootObject: 要归档的对象
        // toFile: 保存的路径
        
        // 对象方法里面需要访问static静态属性需要加类名
        NSKeyedArchiver.archiveRootObject(self, toFile: CZUserAccount.path)
    }
    
    // loadUserAccount方法调用是比较频繁的,每次去沙盒解档账号需要消耗一些性能,当有可用的账号时,保存到对象的属性(内存中,效率非常高).下次使用时,直接使用属性(内存中的账号),可以提高性能
    static var userAccount: CZUserAccount?
    
    class func loadUserAccount() -> CZUserAccount? {
        // 1.去内存(userAccount属性)中看看有没有
        if userAccount == nil {
            // 表示内存没有,去沙盒里面解档账户信息
            // 沙盒里面也不一定能解档出账户信息
            userAccount = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? CZUserAccount
        }
        
        // 不能确定一定有对象, 有账号,并且没有过期,认为这个账号是可用的
        if userAccount != nil && userAccount?.expires_Date?.compare(NSDate()) == NSComparisonResult.OrderedDescending {
            print("加载到可用账号..")
            
            return userAccount
        }
        
        // 能到下面来,要么没有账号,要么是过期的
        return nil
    }
    
    // 程序一开始没有账号需要解档.写成类方法
    // 用户账户信息不一定存在,没有登陆,AccessToken过期了
//    class func loadUserAccount() -> CZUserAccount? {
//        // 解档
//        // 去沙盒解档账号
//        if let userAccount = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? CZUserAccount {
//            // 能到这里面来,说明userAccount有值
//            // NSDate()表示系统当前时间
//            // 判断AccessToken是否过期,将账号的过期时间和当前时间比较, 左边 > 右边没有过期(降序)
//            
//            // 测试过期时间是否有效
////            userAccount.expires_Date = NSDate(timeIntervalSinceNow: -100)
//            if userAccount.expires_Date?.compare(NSDate()) == NSComparisonResult.OrderedDescending {
//                // 没有过期,账号可用
//                print("加载到可用账号")
//                return userAccount
//            } else {
//                print("账号过期")
//                return nil
//            }
//            
//        } else {
//            print("没有加载到账号")
//        }
//        
//        return nil
//    }
}
