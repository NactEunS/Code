//
//  CZRefreshControl.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/23.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

// 自定义刷新控件.里面会包含一个自定的view
class CZRefreshControl: UIRefreshControl {
    
    private let RefreshControlOffestY: CGFloat = -60
    
    // 定义一个标示,记录箭头是否朝上
    private var isUp = false
    
    // 覆盖父类的属性,监听frame的改变
    override var frame: CGRect {
        didSet {
//            print("frame: \(frame)")
            
            // 1.origin.y大于0,看不到刷新控件
            if frame.origin.y > 0 {
                return
            }
            
            // 判断refreshing 是否正在刷新
            if refreshing {
//               print("正在刷新数据")
                refreshView.startLoading()
            }
            
            // 小于 -60,之前箭头需要朝下, 箭头转上去
            if frame.origin.y < RefreshControlOffestY && !isUp {
                isUp = !isUp
//                print("箭头转上去动画")
                refreshView.rotationTipIcon(isUp)
            } else if frame.origin.y > RefreshControlOffestY && isUp {  // 0 到 -60之间,之前箭头需要朝上
                isUp = !isUp
//                print("箭头转下来动画")
                refreshView.rotationTipIcon(isUp)
            }
        }
    }
    
    /// 重写父类的方法.自己来做额外的事情
    override func endRefreshing() {
        super.endRefreshing()
        
//        print("结束刷新")
        
        refreshView.endLoading()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        prepareUI()
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        // 添加控件
        // view从xib里面加载出来的时候,已经有大小,大小是在xib里面设置的大小
        addSubview(refreshView)
        
        // 添加约束
        refreshView.ff_AlignInner(type: ff_AlignType.CenterCenter, referView: self, size: refreshView.bounds.size)
    }

    // MARK: - 懒加载
    /// 自定义的view,从xib里面加载view
    lazy var refreshView: CZRefreshView = CZRefreshView.refreshView()
}

// 自定义的刷新控件的view
class CZRefreshView: UIView {
    
    // MARK: - 属性
    /// 箭头
    @IBOutlet weak var tipIcon: UIImageView!
    
    /// 加载时需要隐藏view.箭头的父控件
    @IBOutlet weak var tipView: UIView!
    
    @IBOutlet weak var juhua: UIImageView!
    
    // 从xib把view加载出来
    class func refreshView() -> CZRefreshView {
        // xib的路径
        let view = NSBundle.mainBundle().loadNibNamed("RefreshView", owner: nil, options: nil).last as! CZRefreshView
        return view
    }
    
    // MARK: - 箭头旋转
    /**
    箭头旋转
    
    - parameter isUp: isUp = true,箭头转上去, isUp = false,箭头转下来
    */
    func rotationTipIcon(isUp: Bool) {
        UIView.animateWithDuration(0.25) { () -> Void in
            self.tipIcon.transform = isUp ? CGAffineTransformMakeRotation(CGFloat(M_PI - 0.001)) : CGAffineTransformIdentity
        }
    }
    
    // MARK: - 菊花旋转
    /// 菊花旋转
    func startLoading() {
        let animKey = "animKey"
        // 1.判断动画是否正在执行,如果正在执行,直接返回
        if juhua.layer.animationForKey(animKey) != nil {
            // 表示动画正在执行
//            print("动画正在执行,什么都不干")
            return
        }
        
        // 2. 隐藏tipView
        tipView.hidden = true
        
        // 3.旋转菊花
        // 3.1创建核心动画
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        // 3.2设置核心动画参数
        anim.toValue = 2 * M_PI
        anim.duration = 0.25
        anim.repeatCount = MAXFLOAT
        anim.removedOnCompletion = false
        
        // 3.3开始核心动画
        juhua.layer.addAnimation(anim, forKey: animKey)
    }
    
    // MARK: - 结束加载
    /// 结束加载
    func endLoading() {
        // 显示箭头所在的view
        tipView.hidden = false
        
        // 关闭菊花旋转
        juhua.layer.removeAllAnimations()
    }
}