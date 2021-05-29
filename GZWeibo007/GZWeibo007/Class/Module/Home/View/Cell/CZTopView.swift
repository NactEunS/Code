//
//  CZTopView.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/20.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

import SDWebImage

class CZTopView: UIView {
    
    // 顶部视图显示内容需要模型
    var status: CZStatus? {
        didSet {
            // 当cell给顶部视图设置模型时,顶部视图根据模型来显示数据
            
            // 1.显示头像
            if let profile_image_url = status?.user?.profile_image_url {
                let url = NSURL(string: profile_image_url)!
                iconView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "avatar"))
            }
            
            // 2.用户名称
            // nameLabel.text 是一个选
            nameLabel.text = status?.user?.screen_name
            
            // 3.时间
            timeLabel.text = "刚刚"
            
            // 4.来源
            sourceLabel.text = "火星"
            
            // 5.会员等级
            
            /*
                模型里面只提供一个mbrank或verified_type,外面调用的时候需要判断,根据不同的值爱设置不同的图片.代码有点多,如果其他地方也要使用mbrank或verified_type,又要重复判断,最好的做法是让模型直接提供对应的图片,直接使用对应的图片.外面使用比较方便.尤其是在多处使用的时候
            */
            // 根据不同的等级显示不同的图片
//            if let mbrank = status?.user?.mbrank {
//                if mbrank > 0 && mbrank <= 6 {
//                    vipView.image = UIImage(named: "common_icon_membership_level\(mbrank)")
//                } else {
//                    // 清空图片,防止cell复用
//                    vipView.image = nil
//                }
//            }
            
            // 根据不同的等级显示不同的图片
            vipView.image = status?.user?.mbrankImage
            
            // 6.认证图标
//            if let verified_type = status?.user?.verified_type {
//                // 根据不同的认证类型,显示不同的认证图标
//                switch verified_type {
//                case 0:
//                    verifiedView.image = UIImage(named: "avatar_vip")
//                case 2, 3, 5:
//                    verifiedView.image = UIImage(named: "avatar_enterprise_vip")
//                case 220:
//                    verifiedView.image = UIImage(named: "avatar_grassroot")
//                default:
//                    verifiedView.image = nil
//                }
//            }
            // 外面调用非常简单
            verifiedView.image = status?.user?.verifiedImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 修改颜色
//        self.backgroundColor = UIColor.brownColor()
        
        // 准备UI
        prepareUI()
    }
    
    private func prepareUI() {
        // 1.添加子控件
        addSubview(separatorView)
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        addSubview(vipView)
        addSubview(verifiedView)
        
        // 2.添加约束
        separatorView.ff_AlignInner(type: ff_AlignType.TopLeft, referView: self, size: CGSize(width: UIScreen.mainScreen().bounds.width, height: 10))
        
        // 头像
        iconView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: separatorView, size: CGSize(width: 35, height: 35), offset: CGPoint(x: 8, y: 8))
        
        // 名称
        nameLabel.ff_AlignHorizontal(type: ff_AlignType.TopRight, referView: iconView, size: nil, offset: CGPoint(x: 8, y: 0))
        
        // 时间
        timeLabel.ff_AlignHorizontal(type: ff_AlignType.BottomRight, referView: iconView, size: nil, offset: CGPoint(x: 8, y: 0))
        
        // 来源
        sourceLabel.ff_AlignHorizontal(type: ff_AlignType.CenterRight, referView: timeLabel, size: nil, offset: CGPoint(x: 8, y: 0))
        
        // 会员等级
        vipView.ff_AlignHorizontal(type: ff_AlignType.CenterRight, referView: nameLabel, size: CGSize(width: 14, height: 14), offset: CGPoint(x: 8, y: 0))
        
        // 认证图标
        verifiedView.ff_AlignInner(type: ff_AlignType.BottomRight, referView: iconView, size: CGSize(width: 17, height: 17), offset: CGPoint(x: 8.5, y: 8.5))
    }

    // MARK: - 懒加载
    /// cell的分割视图
    private lazy var separatorView: UIView = {
        let view = UIView()
        
        // 设置背景
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        return view
    }()
    
    /// 用户头像
    private lazy var iconView: UIImageView = UIImageView(image: UIImage(named: "avatar"))
    
    /// 用户名称
    private lazy var nameLabel: UILabel = UILabel(color: UIColor.darkGrayColor(), fontSize: 14)
    
    /// 微博时间
    private lazy var timeLabel: UILabel = UILabel(color: UIColor.orangeColor(), fontSize: 9)
    
    /// 微博来源
    private lazy var sourceLabel: UILabel = UILabel(color: UIColor.lightGrayColor(), fontSize: 9)
    
    /// 会员等级
    private lazy var vipView: UIImageView = UIImageView(image: UIImage(named: "common_icon_membership_expired"))
    
    /// 认证图标
    private lazy var verifiedView: UIImageView = UIImageView(image: nil)
}
