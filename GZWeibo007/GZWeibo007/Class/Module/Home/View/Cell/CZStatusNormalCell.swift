//
//  CZStatusNormalCell.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/21.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

/// 原创cell
class CZStatusNormalCell: CZStatusCell {

    /// 覆盖父类的方法,添加配图的约束
    override func preapreUI() {
        super.preapreUI()
        
        // 微博配图
        let cons = pictureView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: contentLabel, size: CGSize(width: 290, height: 290), offset: CGPoint(x: 0, y: 8))

        // 获取微博配图视图的宽高约束
        // 注意: 设置约束的时候需要设置 size， 不然框架不会添加宽高约束,拿不到宽高约束
        pictureViewWidthCon = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
        pictureViewHeightCon = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
    }
}
