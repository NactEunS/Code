//
//  CZOauthViewController.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/18.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

import SVProgressHUD

class CZOauthViewController: UIViewController, UIWebViewDelegate {
    
    /// WebView开始加载
    func webViewDidStartLoad(webView: UIWebView) {
        // 显示正在加载
        // showWithStatus会一直显示
        // showInfoWithStatus,过1s自动关闭
        SVProgressHUD.showWithStatus("正在加载", maskType: SVProgressHUDMaskType.Black)
    }
    
    /// WebView加载完毕
    func webViewDidFinishLoad(webView: UIWebView) {
        // 关闭指示器
        SVProgressHUD.dismiss()
    }
    
    /// webView是否要去加载一个网址,返回true去加载, false不去加载
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL!.absoluteString
        print("url： \(url)")
        
        //只有点击 取消或授权,才会加载 授权回调地址,其他情况不会加载授权回调地址
        // 不是授权回调地址,直接加载
        if !url.hasPrefix(CZNetworkTool.sharedInstance.redirect_uri) {
            // 返回true去加载
            return true
        }
        
        /*
            当我们授权同意,获取过AccessToken之后,在登录不会弹出授权界面,如果还想弹出来需要先取消授权,取消授权需要到微博界面去
        */
        
        // 2.是授权回调地址,判断是取消还是授权
        // 点击取消: http://www.baidu.com/?error_uri=%2Foauth2%2Fauthorize&error=access_denied&error_description=user%20denied%20your%20request.&error_code=21330
        // 点击授权:会以code=开头 http://www.baidu.com/?code=a61c2d7ec7b8c4c9c1962bf4354354c5
        // 获取url中?后面的内容: URL.query就是问号后面的东西
        if let query = request.URL?.query {
            // 能到这里面来,表示query有值
            let codeString = "code="
            // 判断query是否以code=开头
            
            if query.hasPrefix(codeString) {
                // 截取code的值
                // Stirng和NSString之间的转换是不需要添加as? 或 as! 直接使用as
                // 3.截取code
                let queryNS = query as NSString
                let code = queryNS.substringFromIndex(codeString.characters.count)
                print("code = \(code)")
                
                // 4.调用当前类的loadAccessToken
                loadAccessToken(code)
            } else {
                self.close()
            }
            
        } else {
             print("query没有值")
        }
        
        return false
    }
    
    // 控制器加载AccessToken
    func loadAccessToken(code: String) {
        // 5.调用网络工具类加载AccessToken,准备好了一个闭包
        CZNetworkTool.sharedInstance.loadAccessToken(code) { (result, error) -> () in
            // 9.判断网络请求是否有错误
            // error == nil 模拟失败
            if error != nil && result == nil {
                print("error: \(error)")
                
                SVProgressHUD.showInfoWithStatus("您的网络不给力")
                
                // 9.1延迟1秒再关闭
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                    
                    // 9.2关闭授权控制器
                    self.close()
                })
                
                return
            }
            
            // 能到下面来没有错误,获取到了AccessToken
            // 保存AccessToken
//            print("result: \(result)")
            // 10.字典转模型
            let userAccount = CZUserAccount(dict: result!)
            
            // 11.保存对象到沙盒
            userAccount.saveUserAccount()
            print("userAccount: \(userAccount)")
            
            // 12.切换到欢迎界面
//            (UIApplication.sharedApplication().delegate as! AppDelegate).switchRootViewController(false)
            
            // 别人调用比较简单
            AppDelegate.outSwitchRootViewController(false)
            
            // 13.关闭登录界面
            self.close()
        }
    }
    
    // 在这赋值的话,不需要添加约束,系统会自动添加约束
    override func loadView() {
        view = webView
        
        // 监听webView加载网络地址
        webView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 这样添加是可以的,缺点是需要我们自己手动来添加约束
//        view.addSubview(webView)
        
        // 1.加载登陆界面,url在CZNetworkTool准备好了
        let url = CZNetworkTool.sharedInstance.oAuthURL()
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
        
        // 设置导航栏
        // 左边,填充
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "填充", style: UIBarButtonItemStyle.Plain, target: self, action: "autoFill")
        
        // 右边,取消
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "close")
        
        navigationItem.title = "登陆"
    }
    
    /// 填充账号密码
    func autoFill() {
        // 创建js代码
        let js = "document.getElementById('userId').value='czbkiosweibo@163.com'; document.getElementById('passwd').value='czbkios007';"
        
        // 让webView来执行js代码
        webView.stringByEvaluatingJavaScriptFromString(js)
    }
    
    /// 关闭
    func close() {
        SVProgressHUD.dismiss()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - 懒加载
    // WebView
    private lazy var webView = UIWebView()
}
