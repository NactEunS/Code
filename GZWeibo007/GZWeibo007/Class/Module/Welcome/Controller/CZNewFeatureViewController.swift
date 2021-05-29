//
//  CZNewFeatuerViewController.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/17.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CZNewFeatureViewController: UICollectionViewController {
    
    // 流水布局
    private let layout = UICollectionViewFlowLayout()
    
    // AppDelegate会调用没有参数的构造函数
    init() {
        // 调用父类的需要layout的构造函数
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 属性
    /// 新特性界面数量
    private let ItemCount = 4

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareCollectionView()
    }
    
    // MARK: - 准备collectionView的相关参数
    private func prepareCollectionView() {
        // 注册cell
        // UICollectionViewCell.self 等价于 [UICollectionViewCell class]
        self.collectionView!.registerClass(CZNewFeatureCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // 设置布局参数
        // 一个item和屏幕一样大
        layout.itemSize = UIScreen.mainScreen().bounds.size
        
        // 不要间距
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        // 水平滚动
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        // 分页显示
        collectionView?.pagingEnabled = true
        
        // 取消弹簧效果
        collectionView?.bounces = false
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ItemCount
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // 去缓存池中查找
        // as 类型转换, 但是有可能转成功,也有可能转失败
        // as! 表示一定能转成功,如果一旦转换失败,程序崩溃
        // as? 表示有可能转成功,也有可能转不成功, 返回值是一个可选
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CZNewFeatureCell
    
        // 设置背景色
//        cell.backgroundColor = UIColor.brownColor()
        
        // collectionView使用indexPath.item
        // tableView使用indexPath.row
        cell.index = indexPath.item
        
        // 不能直接在这里动画,一显示cell的时候就会动画,我们想要停下来时动画
//        cell.startButtonAnimation()
    
        return cell
    }
    
    // collectionView显示完毕时调用(在屏幕上看不到的时候会调用)
    // collectionView停到某一页
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
//        print("indexPath: \(indexPath)")
        // collectionView停到某一页,不使用indexPath,我们自己来获取现在正在显示的cell indexPath
        let visibleIndexPath = collectionView.indexPathsForVisibleItems().last!  // z正在显示的所有cell的IndexPath
//        print("正在显示cell的indexPath: \(visibleIndexPath)")
        
        // 判断是否是最后一个
        if visibleIndexPath.item == ItemCount - 1 {
            // 获取visibleIndexPath对应的cell
            let cell = collectionView.cellForItemAtIndexPath(visibleIndexPath) as! CZNewFeatureCell
            
            // 调用cell开始动画
            cell.startButtonAnimation()
        }
    }
    
    // 当scrollView停下来时,判断是否是最后一页,如果是最后一页让开始按钮做动画
}

// MARK: - 自定义cell显示新特性界面
class CZNewFeatureCell: UICollectionViewCell {
    
    // MARK: - 属性
    // 不同的cell显示不同的图片,别人告诉我们显示哪一页的图片
    // 根据不同的index来设置不同的图片
    var index = 0 { // 0 - 3
        // 属性监视器, 当index发生变化时会调用
        didSet {
            // 找对对应的图片,设置给背景视图
            bkgImageView.image = UIImage(named: "new_feature_\(index + 1)")
            
            // 每当cell要显示之前都隐藏开始按钮
            startButton.hidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 系统会来调用
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    // MARK: - 开始按钮动画
    func startButtonAnimation() {
        // 显示按钮
        startButton.hidden = false
        
        // 设置开始按钮的scale
        startButton.transform = CGAffineTransformMakeScale(0, 0)
        
        // 使用UIView动画
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            // 将开始按钮的transform的缩放设置成1(x,y)
//            self.startButton.transform = CGAffineTransformMakeScale(1, 1)
            // 清空transform
            self.startButton.transform = CGAffineTransformIdentity
            }) { (_) -> Void in
                print("开始按钮动画完成")
        }
    }

    // MARK: - 准备UI
    private func prepareUI() {
        // 添加子控件, TableViewCell和CollectionViewCell,添加子控件需要添加到contentView上面
        contentView.addSubview(bkgImageView)
        contentView.addSubview(startButton)
        
        // 添加约束
//        bkgImageView.translatesAutoresizingMaskIntoConstraints = false
//        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 背景填充父控件
//         哪个控件要填充父控件,就哪个控件调用ff_Fill
        // referView: 要填充的父控件
        // insets: 边距
        bkgImageView.ff_Fill(contentView)
//        bkgImageView.ff_Fill(contentView, insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
//        contentView.addConstraint(NSLayoutConstraint(item: bkgImageView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
//        
//        contentView.addConstraint(NSLayoutConstraint(item: bkgImageView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
//        
//        contentView.addConstraint(NSLayoutConstraint(item: bkgImageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
//        
//        contentView.addConstraint(NSLayoutConstraint(item: bkgImageView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        // 开始体验按钮约束
        // 水平CenterX和父控件的CenterX重合
        
        // 哪个控件要添加约束,就哪个控件调用
        // type: 具体的位置
        startButton.ff_AlignInner(type: ff_AlignType.BottomCenter, referView: contentView, size: nil, offset: CGPoint(x: 0, y: -160))
        
//        contentView.addConstraint(NSLayoutConstraint(item: startButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
//        
//        // 垂直开始按钮的底部和父控件的底部重合
//        contentView.addConstraint(NSLayoutConstraint(item: startButton, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -160))
    }
    
    // MARK: - 点击事件
    func startButtonClick() {
        // 调用AppDelegate来切换根控制器,不能直接创建AppDelegate(),需要使用系统维护的AppDelegate
//        (UIApplication.sharedApplication().delegate as! AppDelegate).switchRootViewController(true)
        AppDelegate.outSwitchRootViewController(true)
    }
    
    // MARK: - 懒加载, 按钮会自动适配图片的大小
    /// 背景图片.
    private lazy var bkgImageView: UIImageView = UIImageView(image: UIImage(named: "new_feature_1"))
    
    /// 开始按钮
    private lazy var startButton: UIButton = {
        let button = UIButton()
        
        // 设置背景图片
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button"), forState: UIControlState.Normal)
        button.setBackgroundImage(UIImage(named: "new_feature_finish_button_highlighted"), forState: UIControlState.Highlighted)
        
        // 设置按钮文字
        button.setTitle("开始体验", forState: UIControlState.Normal)
        
        // 因为cell复用,不能再创建的时候来隐藏cell
//        button.hidden = true
        
        // 按钮添加点击事件
        button.addTarget(self, action: "startButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        return button
    }()
}