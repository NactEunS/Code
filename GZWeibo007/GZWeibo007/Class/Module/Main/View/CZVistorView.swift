//
//  CZVistorView.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/15.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

// 1.懒加载所有控件
// 2.添加控件
// 3.设置位置

// 注册和登陆按钮点击事件协议
protocol CZVisitorViewDelegate: NSObjectProtocol {
    // 协议里面默认是必须实现的
    // 注册按钮被点击
    func visitorViewRegisterClick()
    
    // 登陆按钮被点击
    func visitorViewLoginClick()
}

class CZVistorView: UIView {
    
    // 代理, 有可能有,有可能没有
    // 默认是strong
    weak var delegate: CZVisitorViewDelegate?
    
    // 子类实现了构造方法,不会继承父类的构造方法
    // view必须能从从xib/storyboard
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 修改背景颜色
        backgroundColor = UIColor(white: 237 / 255.0, alpha: 1)
        
        prepareUI()
    }
    
    // 转轮旋转的动画
    func startRotationAnimation() {
        // 核心动画, 旋转
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        // 设置参数
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 20
        
        // 动画完成时不移除，当我们切换到其他界面,动画就结束了
        anim.removedOnCompletion = false
        
        // 给图层添加核心动画
        iconView.layer.addAnimation(anim, forKey: nil)
    }
    
    /// 暂停旋转
    func pauseAnimation() {
        // 记录暂停时间
        let pauseTime = iconView.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        
        // 设置动画速度为0
        iconView.layer.speed = 0
        
        // 设置动画偏移时间
        iconView.layer.timeOffset = pauseTime
    }
    
    /// 恢复动画
    func resumeAnimation() {
        // 获取暂停时间
        let pauseTime = iconView.layer.timeOffset
        
        // 设置动画速度为1
        iconView.layer.speed = 1
        
        // 重置偏移时间
        iconView.layer.timeOffset = 0
        
        // 重置开始时间
        iconView.layer.beginTime = 0
        
        // 计算开始时间
        let timeSincePause = iconView.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pauseTime
        
        // 设置开始时间
        iconView.layer.beginTime = timeSincePause
    }
    
    // 访客视图提供一个方法让别人来设置内容
    // 只有除首页外的3控制器来设置内容
    func setupVisitorInfo(imageName: String, message: String) {
        // 替换转轮的图片
        iconView.image = UIImage(named: imageName)
        
        // 隐藏小房子
        homeView.hidden = true
        
        // 遮罩弄到最底部
        // self:父控件
        // sendSubviewToBack: 将子控件放到最底部
//        self.sendSubviewToBack(coverView)
        coverView.hidden = true
        
        // 消息label内容
        messageLabel.text = message
    }
    
    /// 准备UI
    private func prepareUI() {
        // 添加子控件
        addSubview(iconView)
        
        // 添加遮罩,注意位置
        addSubview(coverView)
        
        addSubview(homeView)
        addSubview(messageLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        
        // Autoresizing影响AutoLayout的约束
        iconView.translatesAutoresizingMaskIntoConstraints = false
        coverView.translatesAutoresizingMaskIntoConstraints = false
        homeView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置位置
        // 使用AutoLayout来布局
        
        // 约束转轮CenterX和父控件的CenterX重合
        // item: 需要约束的view
        // attribute: 要约束的属性 CenterX
        
        // 将约束对象添加到父控件self上面去
        self.addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))

        // 约束转轮CenterY和父控件的CenterY重合
        // 将约束添加到父控件self上面
        self.addConstraint(NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: -40))
        
        // 房子参照转轮
        // CenterX和转轮的CenterX重合
        // 约束统一添加到父控件上面
        self.addConstraint(NSLayoutConstraint(item: homeView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        
        // 房子CenterY和转轮的CenterY重合
        self.addConstraint( NSLayoutConstraint(item: homeView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // 消息label CenterX和转轮CenterX重合
        self.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        
        // 消息label的顶部,距离转轮的底部16
        self.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        
        // 消息label宽度约束
        self.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 240))
        
        // 注册按钮
        // 宽100
        // 不参照任何对象: toItem 填nil attribute: 必须填: NSLayoutAttribute.NotAnAttribute
        self.addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100))
        
        // 高度35
        self.addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        // 注册按钮顶部距离消息label 底部16
        self.addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        
        // 注册按钮左边和消息label左边重合
        self.addConstraint(NSLayoutConstraint(item: registerButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        // 登陆按钮
        // 宽100
        // 不参照任何对象: toItem 填nil attribute: 必须填: NSLayoutAttribute.NotAnAttribute
        self.addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 100))
        
        // 高度35
        self.addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        // 登陆按钮顶部距离消息label 底部16
        self.addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 16))
        
        // 登陆按钮右边和消息label右边重合
        self.addConstraint(NSLayoutConstraint(item: loginButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: messageLabel, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        
        // 遮罩约束,填充父控件
        // 左边
        self.addConstraint(NSLayoutConstraint(item: coverView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        
        // 右边
        self.addConstraint(NSLayoutConstraint(item: coverView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        
        // 顶部
        self.addConstraint(NSLayoutConstraint(item: coverView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        
        // 底部,参照注册按钮底部
        self.addConstraint(NSLayoutConstraint(item: coverView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: registerButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    }
    
    // MARK: - 按钮点击事件
    // 点击事件的方法,使用private修饰,系统会找不到方法
    // 加了 private 后系统不会自动添加 @objc, 系统不认识
    @objc private func registerClick() {
        // 调用代理通知控制器按钮被点击
        // delegate有值就调用visitorViewRegisterClick
        // delegate没有值就不执行visitorViewRegisterClick
        delegate?.visitorViewRegisterClick()
    }
    
    func loginClick() {
        // view是不能modal出来控制器, 只有控制器才能modal出来
        // 点击事件需要传给控制器
        
        delegate?.visitorViewLoginClick()
    }

    // MARK: - 懒加载
    /// 转轮
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
    
    /// 小房子
    private lazy var homeView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    
    /// 消息
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        
        // 设置文字
        label.text = "关注一些人,看看这里有什么惊喜!"
        
        label.textColor = UIColor.darkGrayColor()
        
        // 显示多行
        label.numberOfLines = 0
        
        return label
    }()
    
    /// 注册按钮
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        
        // 设置按钮背景
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        
        // 设置按钮文字
        button.setTitle("注册", forState: UIControlState.Normal)
        
        // 设置文字颜色
        button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        
        // 添加点击事件
        button.addTarget(self, action: "registerClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
    
    /// 登陆按钮
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        
        // 设置按钮背景
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        
        // 设置按钮文字
        button.setTitle("登陆", forState: UIControlState.Normal)
        
        // 设置文字颜色
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        button.addTarget(self, action: "loginClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
    
    // 遮罩视图
    private lazy var coverView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
}
