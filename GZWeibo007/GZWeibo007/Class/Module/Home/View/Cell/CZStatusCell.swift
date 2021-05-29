//
//  CZStatusCell.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/20.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

// 微博cell基本类.原创cell和转发cell都是继承自CZStatusCell
class CZStatusCell: UITableViewCell {
    
    // MARK: - 属性
    /// 配图宽度约束
    var pictureViewWidthCon: NSLayoutConstraint?
    
    /// 配图高度约束
    var pictureViewHeightCon: NSLayoutConstraint?
    
    // cell显示内容需要模型
    var status: CZStatus? {
        didSet {
            // 当控制器给cell设置模型后,顶部视图显示数据也是依赖模型
            topView.status = status
            
            // 设置微博的内容
            contentLabel.text = status?.text
            
            // 将模型设置给配图视图.
            pictureView.status = status
            
            // 调用配图视图的计算尺寸的方法
            let size = pictureView.calcViewSize()
//            print("配图的size: \(size)")
            
            // 修改配图的高度
            pictureViewHeightCon?.constant = size.height
            pictureViewWidthCon?.constant = size.width
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 准备UI
        preapreUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 计算行高
    /// cell自己计算行高
    func rowHeight(status: CZStatus) -> CGFloat {
        // 设置cell的status,cell会根据status里面的内容重新设置每个控件的内容
        self.status = status
        
        // 更新布局,系统会根据控件的内容和约束重新布局每个控件位置和大小
        layoutIfNeeded()
        
        // 获取底部视图的最大的Y值
        let maxY = CGRectGetMaxY(bottomView.frame)
        return maxY
    }
    
    // MARK: - 准备UI
    func preapreUI() {
        // 1. 添加控件
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(bottomView)
        contentView.addSubview(pictureView)
        
        // 2. 添加约束
        topView.ff_AlignInner(type: ff_AlignType.TopLeft, referView: contentView, size: CGSize(width: UIScreen.mainScreen().bounds.width, height: 53))
        
        // 微博文本
        contentLabel.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: topView, size: nil, offset: CGPoint(x: 8, y: 8))
        
        // 微博文本宽度约束
        contentView.addConstraint(NSLayoutConstraint(item: contentLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: UIScreen.mainScreen().bounds.width - 2 * 8))
        
//        // 微博配图
//        let cons = pictureView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: contentLabel, size: CGSize(width: 0, height: 290), offset: CGPoint(x: 0, y: 8))
//        
//        // 获取微博配图视图的宽高约束
//        // 注意: 设置约束的时候需要设置 size， 不然框架不会添加宽高约束,拿不到宽高约束
//        pictureViewWidthCon = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
//        pictureViewHeightCon = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
        
        // 底部视图
        bottomView.ff_AlignVertical(type: ff_AlignType.BottomLeft, referView: pictureView, size: CGSize(width: UIScreen.mainScreen().bounds.width, height: 44), offset: CGPoint(x: -8, y: 8))
        
        // 1.tableView cell 的高度想通过cell里面的内容来自适应,需要给contentView添加约束,让contentView的高度参照里面的内容来自动更改高度(需要添加顶部和底部约束)
        
        // 添加contentView底部约束,contentView底部和contentLabel底部重合
        // TODO:有错误,约束冲突.当配图视图的高度随机时,系统会报约束冲突.,只有去掉自己给contentView添加的底部约束
//        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: bottomView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
    }

    // MARK: - 懒加载
    /// 顶部视图
    private lazy var topView: CZTopView = CZTopView()
    
    /// 微博文本内容
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        
        // 字体大小
        label.font = UIFont.systemFontOfSize(14)
        
        // 字体颜色
        label.textColor = UIColor.darkGrayColor()
        
        // 换行
        label.numberOfLines = 0
        
        // 设置折行文本宽度(换行的宽度)
        label.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 2 * 8
        
        return label
    }()
    
    /// 微博配图视图
    lazy var pictureView: CZStatusPictureView = CZStatusPictureView()
    
    /// 底部视图
    lazy var bottomView: CZStatusBottomView = CZStatusBottomView()
}
