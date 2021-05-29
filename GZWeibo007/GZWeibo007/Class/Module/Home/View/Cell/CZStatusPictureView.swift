//
//  CZStatusPictureView.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/21.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

import SDWebImage

class CZStatusPictureView: UICollectionView {

    // MARK: - 属性
    private let ReuseIdentifier = "StatusPictureViewReuseIdentifier"
    
    /// 微博模型,用于显示图片和计算配图视图的尺寸
    var status: CZStatus? {
        didSet {
            // 防止cell重用,需要刷新数据
            self.reloadData()
        }
    }
    
    /**
     计算配图的尺寸,根据模型里面图片的数量来计算
     
     - returns: 计算好的宽高
     */
    func calcViewSize() -> CGSize {
        // itemSize
        let itemSize = CGSize(width: 90, height: 90)
        
        // 间距
        let margin: CGFloat = 10
        
        // 设置layout的参数
        layout.itemSize = itemSize
        // 间距
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        // 获取图片数量(原创微博,返回原创微博的图片数量,转发微博,显示被转发微博的图片),如果没有值,默认为0
        let count = status?.pictureURLs?.count ?? 0
        
        // 判断图片数量
        // 没有图片
        if count == 0 {
            return CGSizeZero
        }
        
        // 1张图片,返回图片的大小
        if count == 1 {
            // 单张图片显示图片原本的大小
            // 需要知道图片的大小,因为新浪的api没有返回图片大小
            // 先将图片下载到本地(SDWebImage).然后就可以获取到图片的大小
            
            // 默认大小,有些图片缓存失败显示默认大小
            var size = CGSize(width: 150, height: 120)
            
            // 判断图片是否缓存了.如果有缓存图片,获取图片的大小
            // 获取图片的url
            let url = status!.pictureURLs![0]
            // 获取图片.之前使用SDWebImage缓存的图片.现在使用SDWebImage来加载图片
            // key: 图片的url地址,String类型
            if let image = SDImageCache.sharedImageCache().imageFromDiskCacheForKey(url.absoluteString) {
                // 有图片,设置itemSize为图片的大小
                size = image.size
            }
            
            // 判断,图片太小
            if size.width < 40 {
                size.width = 40
            } else if size.width > UIScreen.mainScreen().bounds.width * 0.5 {
                size.width = UIScreen.mainScreen().bounds.width * 0.5
            }

            // 设置itemSize
            layout.itemSize = size
            
            // 返回一个固定的大小
            return size
        }
        
        // 设置间距
        layout.minimumInteritemSpacing = margin
        layout.minimumLineSpacing = margin
        
        // 4张图片
        if count == 4 {
            let value = 2 * itemSize.width + margin
            
            return CGSize(width: value, height: value)
        }
        
        // 其他情况
        // 列数,行数计算依赖列数,column必须为Int
        let column = 3
        
        // 宽度 = 列数 * cell的宽度 + (列数 - 1) * 间距
        let width = CGFloat(column) * itemSize.width + (CGFloat(column) - 1) * margin
        
        // 行数 = (图片的数量(Int) + 列数(Int) - 1) / 列数(Int)
        /*
            1 + 3 - 1 / 3 = 1
            2 + 3 - 1 / 3 = 1
            3 + 3 - 1 / 3 = 1
            5 + 3 - 1 / 3 = 2
            6 + 3 - 1 / 3 = 2
            7 + 3 - 1 / 3 = 3
            8 + 3 - 1 / 3 = 3
            9 + 3 - 1 / 3 = 3
        */
        let row = (count + column - 1) / column
        
        // 高度 = 行数 * cell的高度 + (行数 - 1) * 间距
        let height = CGFloat(row) * itemSize.height + (CGFloat(row) - 1) * margin
        return CGSize(width: width, height: height)
    }
    
    private var layout = UICollectionViewFlowLayout()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 外部调用没有参数的构造函数
    init() {
        // 我们里面调用需要布局的构造函数
        super.init(frame: CGRectZero, collectionViewLayout: layout)
        
        // 修改背景颜色
        backgroundColor = UIColor.clearColor()
        
        // 注册cell,使用自定义cell
        self.registerClass(CZStatusPictureViewCell.self, forCellWithReuseIdentifier: ReuseIdentifier)
        // 设置数据源
        self.dataSource = self
    }
}

// MARK: - 扩展 CZStatusPictureView 实现UICollectionViewDataSource
extension CZStatusPictureView: UICollectionViewDataSource {
    
    // 返回图片 cell的数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 没有图片返回0
        return status?.pictureURLs?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // 去缓存池中查找cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReuseIdentifier, forIndexPath: indexPath) as! CZStatusPictureViewCell
        
        // 最好让模型来提供完善一点的数据,直接可以访问图片的NSURL
        
//        // 显示图片.设置图片的url
//        let urlString = status?.pic_urls?[indexPath.item]["thumbnail_pic"] as! String
//        
//        // 创建NSURL
//        let url = NSURL(string: urlString)
//        cell.imageURL = url
        
        // 设置cell显示的图片的NSURL
        cell.imageURL = status?.pictureURLs?[indexPath.item]
        
        return cell
    }
}

// 自定义cell
class CZStatusPictureViewCell: UICollectionViewCell {
    
    // MARK: - 属性
    /// 要显示图片的url
    var imageURL: NSURL? {
        didSet {
            // 显示图片
            imageView.sd_setImageWithURL(imageURL)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 准备UI
        prepareUI()
    }
    
    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件
        contentView.addSubview(imageView)
        
        // 添加约束
        imageView.ff_Fill(contentView)
    }
    
    // MARK: - 懒加载
    /// 图片
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        
        // 设置图片的填充模式
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        // 裁剪
        imageView.clipsToBounds = true
        
        return imageView
    }()
}