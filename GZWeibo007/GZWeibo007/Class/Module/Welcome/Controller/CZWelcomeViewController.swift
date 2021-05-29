//
//  CZWelcomeViewController.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/17.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

import SDWebImage

class CZWelcomeViewController: UIViewController {
    
    // MARK: - 属性
    /// 头像底部约束, 在初始化的时候确定不了约束,在 prepareUI 里面才能确定
    private var iconViewBottomCon: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. 准备UI
        prepareUI()
        
        // 2. 先显示上一次保存的头像
        setIconView()
        
        // 3. 加载最新的用户头像
        CZUserAccount.loadUserAccount()?.loadUserInfo({ (error) -> () in
            // 判断是否有错误
            if error != nil {
                print("控制器,获取用户信息出错了 error: \(error)")
                return
            }
            
            // 获取用户数据没有出错,加载最新的头像
            self.setIconView()
        })
    }
    
    /// 显示当前用户头像
    private func setIconView() {
        // 获取当前的用户头像地址
        if let avatar_large = CZUserAccount.loadUserAccount()?.avatar_large {
            let url = NSURL(string: avatar_large)!
            print("头像 url: \(url)")

            // 显示当前用户头像
            self.iconView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "avatar_default_big"))
        }
    }
    
    // view看的到的时候做动画
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 头像做动画,修改头像底部约束的值,往上是负数
        iconViewBottomCon?.constant = -(UIScreen.mainScreen().bounds.height - 160)
        
        // 带弹簧效果
        // usingSpringWithDamping: 弹簧的效果, 范围是0 - 1, 越小越明显
        // initialSpringVelocity: 初始速度
        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            // 动画
            // 闭包里面需要加self
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                
                // 将label渐变出来
                self.welcomeLabel.alpha = 0
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.welcomeLabel.alpha = 1
                    self.welcomeLabel.hidden = false
                    }, completion: { (_) -> Void in
                        // _ 表示占位,对这个参数不关心
                         print("所有动画完成")
                        
                        // 切换界面
//                        (UIApplication.sharedApplication().delegate as! AppDelegate).switchRootViewController(true)
                        AppDelegate.outSwitchRootViewController(true)
                })
        }
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        // 1.添加子控件
        view.addSubview(bkgImageView)
        view.addSubview(iconView)
        view.addSubview(welcomeLabel)
        
        // 2.添加约束
//        bkgImageView.translatesAutoresizingMaskIntoConstraints = false
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 背景,填充父控件
        bkgImageView.ff_Fill(view)
//        view.addConstraint(NSLayoutConstraint(item: bkgImageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
//        
//        view.addConstraint(NSLayoutConstraint(item: bkgImageView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
//        
//        view.addConstraint(NSLayoutConstraint(item: bkgImageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
//        
//        view.addConstraint(NSLayoutConstraint(item: bkgImageView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        // 头像,水平和父控件重合
        let cons = iconView.ff_AlignInner(type: ff_AlignType.BottomCenter, referView: view, size: CGSize(width: 85, height: 85), offset: CGPoint(x: 0, y: -160))
        
        // 取出头像iconView底部约束赋值给iconViewBottomCon属性
        // 去哪个view上面的约束,就哪个view来调用
        // constraintsList: 要去约束的view上面的所有约束
        // attribute: 要获取的约束的属性
        iconViewBottomCon = iconView.ff_Constraint(cons, attribute: NSLayoutAttribute.Bottom)
        
//        view.addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
//        
//        // 垂直方向头像的底部和父控件的底部重合
//        iconViewBottomCon = NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -160)
//        view.addConstraint(iconViewBottomCon!)
//        
//        // 宽度
//        view.addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 85))
//        
//        // 高度
//        view.addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 85))
        
        // 欢迎的label,参照头像
        // 水平方向,欢迎label水平和头像 centerX重合
        welcomeLabel.ff_AlignVertical(type: ff_AlignType.BottomCenter, referView: iconView, size: nil, offset: CGPoint(x: 0, y: 16))
        
//        view.addConstraint(NSLayoutConstraint(item: welcomeLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
//        
//        // 垂直方欢迎label水平和头像距离头像底部16
//        view.addConstraint(NSLayoutConstraint(item: welcomeLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
    }
    
    // MARK: - 懒加载
    /// 背景
    private lazy var bkgImageView: UIImageView = UIImageView(image: UIImage(named: "ad_background"))
    
    // 头像
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar_default_big"))
        
        // 将图片切成圆的
        imageView.layer.cornerRadius = 42.5
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    // welcome label
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        
        // 设置内容
        label.text = "欢迎归来"
        
        // 设置文字大小
        label.font = UIFont.systemFontOfSize(14)
        
        // 隐藏label
        label.hidden = true
        
        return label
    }()
}
