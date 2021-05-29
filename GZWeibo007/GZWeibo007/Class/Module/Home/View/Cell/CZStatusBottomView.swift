//
//  CZStatusBottomView.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/21.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

class CZStatusBottomView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        // 准备UI
        prepareUI()
    }

    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        addSubview(forwardButton)
        addSubview(commentButton)
        addSubview(zanButton)
        addSubview(separatorViewFirst)
        addSubview(separatorViewSecond)
        
        // 添加约束
        // 3个按钮水平平铺父控件
        self.ff_HorizontalTile([forwardButton, commentButton, zanButton], insets: UIEdgeInsetsZero)
        
        // 分割线1
        separatorViewFirst.ff_AlignHorizontal(type: ff_AlignType.CenterRight, referView: forwardButton, size: nil)
        
        // 分割线2
        separatorViewSecond.ff_AlignHorizontal(type: ff_AlignType.CenterRight, referView: commentButton, size: nil)
    }

    // MARK: - 懒加载控件
    // 转发
    private lazy var forwardButton: UIButton = UIButton(imageName: "timeline_icon_retweet", fontSize: 11, title: "转发")
    
    // 评论
    private lazy var commentButton: UIButton = UIButton(imageName: "timeline_icon_comment", fontSize: 11, title: "评论")
    
    // 赞
    private lazy var zanButton: UIButton = UIButton(imageName: "timeline_icon_unlike", fontSize: 11, title: "赞")
    
    // 分割线1
    private lazy var separatorViewFirst: UIImageView = UIImageView(image: UIImage(named: "timeline_card_bottom_line_highlighted"))
    
    // 分割线1
    private lazy var separatorViewSecond: UIImageView = UIImageView(image: UIImage(named: "timeline_card_bottom_line_highlighted"))
}
