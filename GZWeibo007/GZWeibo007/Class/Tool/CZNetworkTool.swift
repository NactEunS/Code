//
//  CZ.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/17.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

import AFNetworking

// 使用枚举来统一管理错误
enum CZNetworkError: Int {
    case emptyAccessToken = -1  // AccessToken没有值
    case emptyUid = -2  // Uid没有值
    
    // 枚举除了有成员之外,还可以有属性和方法
    // 将错误的code和错误的描述关联起来, 使用计算性属性,只有get(只读计算性属性)
    var errorDescription: String {
        get {
            // 判断不同的类型返回不同的错误信息
            switch self {
            case CZNetworkError.emptyAccessToken:
                return "access_token没有值"
            case CZNetworkError.emptyUid:
                return "uid没有值"
            }
        }
    }
    
    // 定义一个方法,返回一个错误,根据枚举类型不一样返回不一样的错误
    func error() -> NSError {
        return NSError(domain: "cn.itcast.error.network", code: self.rawValue, userInfo: ["errorDescription" : self.errorDescription])
    }
}

// 网络工具类只负责请求数据,请求到数据后回调.不去处理数据
class CZNetworkTool: AFHTTPSessionManager {

    // 单例, 调用默认构造方法
//    static let sharedInstance: CZNetworkTool = {
//        
//        // baseURL,api前面的内容是一样的
//        // https://api.weibo.com/2/statuses/home_timeline.json
//        // https://api.weibo.com/oauth2/authorize
//        let baseURL = NSURL(string: "https://api.weibo.com/")!
//        
//        let tool = CZNetworkTool(baseURL: baseURL)
//        
//        return tool
//    }()
    
    // 单例, 调用默认构造方法
    static let sharedInstance: CZNetworkTool = CZNetworkTool()
    
    // 不让别人访问构造方法
    private init () {
        // 没有初始化的属性
        let baseURL = NSURL(string: "https://api.weibo.com/")!
        // 在构造函数里面子类不能调用父类的便利构造函数,需要调用父类的指定构造函数
//        super.init(baseURL: baseURL)
        super.init(baseURL: baseURL, sessionConfiguration: nil)
        // 方法的调用必须在 super.init 只有 调用父类的super.init之后,对象才创建完毕,对象创建完毕才能调用对象的方法
        
        // 设置响应的序列化器,支持text/plain
        self.responseSerializer.acceptableContentTypes?.insert("text/plain")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 授权相关
    /// app key
    private let client_id = "173700330"
    
    /// app 秘钥
    private let client_secret = "696426f35e8cadf118ba783376857b4d"
    
    /// 授权回调地址
    let redirect_uri = "http://www.baidu.com/"
    
    /// 拼接登陆界面的URL地址
    func oAuthURL() -> NSURL {
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(client_id)&redirect_uri=\(redirect_uri)"
        
        return NSURL(string: urlString)!
    }
    
    // MARK: - 加载AccessToken
    // 当网络请求成功会失败需要告诉调用的对象,使用闭包回调
    func loadAccessToken(code: String, finished: (result: [String: AnyObject]?, error: NSError?) -> ()) {
        // 6.准备相关内容
        // 6.1 url地址, 可以省略前面的baseURL,AFN会自动帮我们加上
        let urlString = "oauth2/access_token"
        
        // 6.2 请求参数,字典
        let parameters = [
            "client_id": client_id,
            "client_secret": client_secret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirect_uri
        ]
        
        // 将响应的序列化器设置为2进制,AFN默认的是json序列化器
//        self.responseSerializer = AFURLResponseSerialization()
        
        // 7.发送POST请求
        POST(urlString, parameters: parameters, success: { (_, result) -> Void in
            // 调用闭包,
            // 需要将返回结果转成字典, 使用 as?,因为闭包的result参数是一个[String : AnyObject]?,说明可以串nil
            // 8.执行准备好的闭包
            let dict = result as? [String : AnyObject]
            finished(result: dict, error: nil)
            }) { (_, error) -> Void in
                // 8.执行准备好的闭包
                finished(result: nil, error: error)
        }
    }
    
    /// MAR: - 加载用户信息
    func loadUserInfo(finished: (result: [String: AnyObject]?, error: NSError?) -> ()) {
//        // 获取AccessToken,判断AccessToken是否有值
//        if let access_token = CZUserAccount.loadUserAccount()?.access_token {
//            // access_token有值,会进来
//            
//            if let uid = CZUserAccount.loadUserAccount()?.uid {
//                // uid有值, 才能去发送请求,代码嵌套会比较多
//            }
//        }
        
        // 1.获取AccessToken,判断AccessToken是否有值
        // 守卫
        
        // 测试accessToken没有值
//        CZUserAccount.loadUserAccount()?.access_token = nil
        guard let access_token = CZUserAccount.loadUserAccount()?.access_token else {
            // 没有值就进来
            // 最好是自定义错误返回给调用的人
            
            // domain: 域,自定义,表示错误的范围
            // code: 自定义,一般是负数开头,表示错误类型
            // userInfo: 错误的附加信息,让别人明确错误的原因
//            let error = NSError(domain: "cn.itcast.error.network", code: -1, userInfo: ["errorDescription" : "access_token没有值"])
            // 1.定义错误枚举
//            let errorEnum = CZNetworkError.emptyAccessToken
//            
//            // 2.创建错误
//            let error = NSError(domain: "cn.itcast.error.network", code: errorEnum.rawValue, userInfo: ["errorDescription" : errorEnum.errorDescription])
            
            let error = CZNetworkError.emptyAccessToken.error()
            
            // 告诉调用者,网络请求出错
            finished(result: nil, error: error)
            return
        }
        
        // 能到这里来说明 access_token 是有值的
        
        // 2.获取用户的uid
        // TODO: 测试UID没有值
//        CZUserAccount.loadUserAccount()?.uid = nil
        guard let uid = CZUserAccount.loadUserAccount()?.uid else {
            // 能到这里面来uid没有值
            
//            let error = NSError(domain: "cn.itcast.error.network", code: -2, userInfo: ["errorDescription" : "uid没有值"])
            
//            // 1.定义错误枚举
//            let errorEnum = CZNetworkError.emptyUid
//            
//            // 2.创建错误
//            let error = NSError(domain: "cn.itcast.error.network", code: errorEnum.rawValue, userInfo: ["errorDescription" : errorEnum.errorDescription])
            
            let error = CZNetworkError.emptyUid.error()
            
            // 告诉调用者,网络请求出错
            finished(result: nil, error: error)
            return
        }
        
        // 能到这里来说明uid是有值的.
        
        // 3.url地址, 可以省略baseURL,AFN会自动帮我们加上
        let urlString = "2/users/show.json"
        
        // 4.请求参数
        let parameters = [
            "access_token": access_token,
            "uid": uid
        ]
        
        // 5.发送请求获取用户数据
        GET(urlString, parameters: parameters, success: { (_, result) -> Void in
            // 6.调用准备好的闭包
            let dict = result as? [String: AnyObject]
            finished(result: dict, error: nil)
            }) { (_, error) -> Void in
                // 6.调用准备好的闭包
                finished(result: nil, error: error)
        }
    }
    
    // MARK: - 获取微博数据
    /**
    加载微博数据(
    
    - parameter finished: 加载完数据的回调
    */
    func loadStatus(since_id: Int, max_id: Int, finished: (result: [String: AnyObject]?, error: NSError?) -> ()) {
        // 5.1. 判断access_token
        guard let access_token = CZUserAccount.loadUserAccount()?.access_token else {
            // access_token没有值
            // 5.1.2创建错误返回调用者
            let error = CZNetworkError.emptyAccessToken.error()
            finished(result: nil, error: error)
            return
        }
        
        // 5.2. url地址
        let urlString = "2/statuses/home_timeline.json"
        
        // 5.3. 请求参数
        var parameters: [String: AnyObject] = ["access_token": access_token]
        
        if since_id > 0 {
            // 表示别人传了since_id, 下拉刷新微博数据
            parameters["since_id"] = since_id
        } else if max_id > 0 {
            // 表示别人传了max_id, 上拉加载更多微博数据
            // 若指定此参数，则返回ID小于或等于max_id的微博,不需要等于的微博
            parameters["max_id"] = max_id - 1
        }
        
        let debug = false
        if debug {
            // debug模式,加载本地数据
            loadLocalStatus(finished)
        } else {
            // 5.4. 发送请求
            GET(urlString, parameters: parameters, success: { (_, result) -> Void in
                // 5.5.闭包回调,获得到数据
                let dict = result as? [String: AnyObject]
                finished(result: dict, error: nil)
                }) { (_, error) -> Void in
                    // 5.5.闭包回调,出现了错误
                    finished(result: nil, error: error)
            }
        }
        
    }
    
    // MARK: - 加载本地数据
    func loadLocalStatus(finished: (result: [String: AnyObject]?, error: NSError?) -> ()) {
        // 1.获取statuses.json的路径
        let path = NSBundle.mainBundle().pathForResource("statuses", ofType: "json")!
        
        // 2.加载到内存中(NSData)
        let data = NSData(contentsOfFile: path)!
        
        // 3.转成json,swift中的异常处理
        // throws表示方法会抛出异常
//        do {
//            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
//            let dict = json as? [String: AnyObject]
//            finished(result: dict, error: nil)
//        } catch {
//            // 如果有异常,会到这里面来执行,程序不会崩溃,会一直往下走
//            print("json转换出现异常了")
//            let error = NSError(domain: "cn.itcast.error.loadlocaleStatus", code: -3, userInfo: ["errorDescription" : "加载本地数据出错"])
//            finished(result: nil, error: error)
//        }
        
        // 强制try,和强制拆包一样,如果出现错误.程序立即停止运行
        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        let dict = json as? [String: AnyObject]
        finished(result: dict, error: nil)
    }
}
