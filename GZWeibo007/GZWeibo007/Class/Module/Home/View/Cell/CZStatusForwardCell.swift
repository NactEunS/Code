//
//  CZStatusForwardCell.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/21.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

/// 转发cell
class CZStatusForwardCell: CZStatusCell {

    // MARK: - 属性
    /// 微博模型,用于显示转发微博的文本和转发微博的图片
    
    /// 覆盖父类的属性 1.添加 override 关键字, 2.必须实现属性监视器 3.先调用父类的属性监视器,在调用子类的属性监视器
    override var status: CZStatus? {
        didSet {
            // 设置被转发微博的文本内容
            // 获取被转发微博模型
            if let forwardStatus = status?.retweeted_status {
                let text = "@\(forwardStatus.user!.screen_name!): \(forwardStatus.text!)"
                forwardLabel.text = text
            }
        }
    }
    
    // 覆盖父类的方法
    override func preapreUI() {
        super.preapreUI()
        
        // 添加子控件
        contentView.addSubview(bkgButton)
        contentView.addSubview(forwardLabel)
        
        // 将背景按钮发送到最底部
        contentView.sendSubviewToBack(bkgButton)
        
        // 添加约束
        /// 背景按钮,左上角,在微博文本label的底部左边
        bkgButton.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: contentLabel, size: nil, offset: CGPoint(x: -8, y: 8))
        
        /// 背景按钮,右下角,在底部视图右上角
        bkgButton.ff_AlignVertical(type: ff_AlignType.TopRight, referView: bottomView, size: nil)
        
        /// 被转发微博文本label,在背景按钮内部,左上角
        forwardLabel.ff_AlignInner(type: ff_AlignType.TopLeft, referView: bkgButton, size: nil, offset: CGPoint(x: 8, y: 8))
        /// 被转发微博文本label宽度
        contentView.addConstraint(NSLayoutConstraint(item: forwardLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: UIScreen.mainScreen().bounds.width - 2 * 8))
        
        // 微博配图
        let cons = pictureView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: forwardLabel, size: CGSize(width: 290, height: 290), offset: CGPoint(x: 0, y: 8))
        
        // 获取微博配图视图的宽高约束
        // 注意: 设置约束的时候需要设置 size， 不然框架不会添加宽高约束,拿不到宽高约束
        pictureViewWidthCon = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
        pictureViewHeightCon = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
    }
    
    // MARK: - 懒加载
    /// 背景
    private lazy var bkgButton: UIButton = {
        let button = UIButton()
        
        // 设置背景颜色
        button.backgroundColor = UIColor(white: 0.88, alpha: 1)
        
        return button
    }()
    
    /// 转发微博的文本内容
    private lazy var forwardLabel: UILabel = {
        let label = UILabel(color: UIColor.darkGrayColor(), fontSize: 14)
        
        // 设置显示多行
        label.numberOfLines = 0
        
        // 设置折行文本宽度(换行的宽度)
        label.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 2 * 8
        
        return label
    }()
}
