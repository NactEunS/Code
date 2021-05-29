//
//  CZHomeViewController.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/15.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

import SVPullToRefresh

/// cell的缓存标识
enum CZStatusCellReuseIdentifier: String {
    case StatusNormalCell = "StatusNormalCell"  // 原创cell的标识
    case StatusForwardCell = "StatusForwardCell"    // 转发cell标识
}

// tableView cell 的高度想通过cell里面的内容来自适应
// 1.需要给contentView添加约束,让contentView的高度参照里面的内容来自动更改高度(需要添加顶部和底部约束)
// 2.设置cell预估行高
// 3.设置cell行高根据约束来自适应

class CZHomeViewController: CZBaseViewController {
    // MARK: - 属性
    /// tipLabel的高度
    let tipLabelHeight: CGFloat = 44
    
    /// 微博数据
    var statuses: [CZStatus]? {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 没有登陆不做一下操作,直接返回
        if !CZUserAccount.userLogin {
            return
        }
        
        // 设置导航栏
        setupNav()
        
        prepareTabelView()
        
//        loadStatus()

        // tableView自带一个刷新控件
        // UIRefreshControl继承自UIControl,1.可以往里面添加控件 2.addTarget
        // 默认的宽度为屏幕的宽度,高度60. frame = (0 0; 375 60)
        refreshControl = CZRefreshControl()

        // 刷新控件监听下拉事件
        refreshControl?.addTarget(self, action: "loadNewStatus", forControlEvents: UIControlEvents.ValueChanged)
        
        // 主动进入刷新状态,只会让刷新控件界面显示刷新,并不会主动触发 UIControlEvents.ValueChanged 事件
        refreshControl?.beginRefreshing()
        
        // 主动触发 UIControlEvents.ValueChanged
        refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    /// 显示下拉刷新了多少条数据
    private func showTipView(count: Int) {
        tipLabel.text = count == 0 ? "没有加载到新的微博数据" : "加载了\(count)条微博数据"
        
        // 添加到导航栏上面
        navigationController?.navigationBar.insertSubview(tipLabel, atIndex: 0)
        
        // 动画下来
        UIView.animateWithDuration(1.25, animations: { () -> Void in
            self.tipLabel.frame.origin.y = self.tipLabelHeight
            }) { (_) -> Void in
                UIView.animateWithDuration(1.25, delay: 0.25, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    self.tipLabel.frame.origin.y = -(self.tipLabelHeight + 20)
                    }, completion: { (_) -> Void in
                        // 移除
//                        tipLabel.removeFromSuperview()
                        print("动画完成")
                })
        }
    }
    
    // MARK: - 加载最新的微博数据
    func loadNewStatus() {
        // 如果没有微博数据, since_id设置为0,加载最新的20条
        // 如果有微博数据,获取最大id的微博
        let since_id = statuses?.first?.id ?? 0
        let max_id = 0
        
        // 1.调用微博模型来加载微博数据(微博模型),
        // 2.准备闭包
        CZStatus.mLoadStatus(since_id, max_id: max_id) { (statuses, error) -> () in
            // 关闭刷新控件(结束刷新)
 
            self.refreshControl?.endRefreshing()
            // 拿到自定义的view来调用endLoading不是太好
//            (self.refreshControl as? CZRefreshControl)?.refreshView.endLoading()
            
            // 7.1 判断错误
            if error != nil {
                print("加载微博数据出错: \(error)")
                return
            }
            
            let count = statuses?.count ?? 0
            
            // 判断如果是下拉刷新,显示下拉刷新了多少条数据
            if since_id > 0 {
                self.showTipView(count)
            }
            
            if count == 0 {
                // 没有加载到数据
                print("没有加载到数据")
                return
            }
            
//            print("加载微博数据 statuses条数: \(count)")

            // 7.2 将微博正文内容显示出来, 赋值给 控制器的statuses属性
            // 如果是下拉刷新,将获取到的新数据,拼接在现有数据的前面
            if since_id > 0 {
                // 表示下拉刷新
                // 最终数据 = 新数据 + 现有数据
                self.statuses = statuses! + self.statuses!
                print("下拉刷新 加载到 \(count)条新数据")
            } else {    // 第一次进入程序,加载最新的20条数据
                self.statuses = statuses
                print("第一次进入程序, 加载了 \(count) 条微博数据")
                // 需要显示上拉加载更多地菊花
                self.tableView.showsInfiniteScrolling = true
            }
        
            print("总共有多少条数据: \(self.statuses?.count)")
        }
    }
    
    /// 上拉加载更多数据
    func loadMoreStatus() {
        let since_id = 0
        let max_id = statuses?.last?.id ?? 0
        
        CZStatus.mLoadStatus(since_id, max_id: max_id) { (statuses, error) -> () in
            // 关闭上拉加载更多数据的控件
            self.tableView.infiniteScrollingView.stopAnimating()
            
            if error != nil {
                print("上拉加载数据出错了")
                return
            }
            
            // 没有出错
            let count = statuses?.count ?? 0
            if count == 0 {
                // 没有加载到数据
                print("没有加载到数据")
                return
            }
            
            // 加载到了数据
            if max_id > 0 {
                // 最终的数据 = 现有数据 + 获取到的数据
                self.statuses = self.statuses! + statuses!
                print("上拉加载到更多数据: \(count)条")
            }
            print("总共有多少条数据: \(self.statuses?.count)")
        }
    }
    
    private func prepareTabelView() {
        // 根据不同的模型显示不同的cell
        // 注册原创cell
        tableView.registerClass(CZStatusNormalCell.self, forCellReuseIdentifier: CZStatusCellReuseIdentifier.StatusNormalCell.rawValue)
        // 注册转发cell
        tableView.registerClass(CZStatusForwardCell.self, forCellReuseIdentifier: CZStatusCellReuseIdentifier.StatusForwardCell.rawValue)
        
        tableView.estimatedRowHeight = 200
        
        // 去掉cell的分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // 不添加这个闭包tableView不会出现菊花,只有添加闭包,当拖动到最后一个cell时会出现菊花,执行闭包
        // 添加上拉加载更多数据的事件(闭包),当拖动到最后一个cell的时候会调用这个闭包
        tableView.addInfiniteScrollingWithActionHandler { () -> Void in
            print("加载更多数据")
            
            // 加载更多数据
            self.loadMoreStatus()
        }
        
        // 先不显示上拉加载更多的菊花
        tableView.showsInfiniteScrolling = false
    }
    
    /// 设置导航栏
    private func setupNav() {
        // 封装按钮3,使用扩展的便利构造函数
        // 导航栏左边
        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "navigationbar_friendsearch")
        
        // 导航栏右边
        navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "navigationbar_pop")
        
        // 设置导航栏title
        // 三目运算符 bool ? 返回1 : 返回2
        // ??: `xx ?? yy`: 表示 ?? 前面可选如果有值,会强制拆包,并且返回这个值, ??前面可选没有值,会返回?? 后面的值
        let title = CZUserAccount.loadUserAccount()?.screen_name ?? "没获取到用户名"
        
        // 创建title按钮
        let titleButton = CZHomeTitleView(imageName: "navigationbar_arrow_down", title: title)
        
        // 添加点击事件
        titleButton.addTarget(self, action: "homeTitleButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        navigationItem.titleView = titleButton
    }
    
    /// 标题按钮点击事件
    func homeTitleButtonClick(button: UIButton) {
        // 1.设置按钮的状态
        button.selected = !button.selected
        
        /*
            UIView动画旋转:
                1.就近原则.
                2.两边一样远会顺时针旋转
        */
        
        // 抽取代码
        UIView.animateWithDuration(0.25) { () -> Void in
            // 根据按钮的选中状态来确定是旋转方向,如果按钮选中,转180°少一点,否则转到默认位置
            button.imageView?.transform = button.selected ? CGAffineTransformMakeRotation(CGFloat(M_PI - 0.001)) : CGAffineTransformIdentity
        }
    }
    
    // MARK: - tableView数据源和代理
    // 返回每个cell的高度
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        print("heightForRowAtIndexPath: \(indexPath)")
        // 根据不同的模型,计算出cell的高度
        // 1.获取模型
        let status = self.statuses![indexPath.row]
        
        // 2.查看模型是否有缓存的行高,如果有缓存的行高直接返回
        if status.rowHeight != nil {
            // 有缓存的行高
//            print("返回缓存行高: \(status.rowHeight)")
            return status.rowHeight!
        }
        
        // 没有缓存行高
        // 3.获取cell(需要根据不同的模型,获取对应的cell),使用不带IndexPath方法
        let cellID = status.cellID()
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! CZStatusCell
        
        // 调用这个方法,会再次调用heightForRowAtIndexPath来获取行高,会出现递归.
//        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier, forIndexPath: indexPath) as! CZStatusCell
        
        // 4.使用cell计算行高,每次都计算行高需要消耗性能,将行高进行缓存,行高是根据模型算出来的.行高缓存在模型中最合适
        let rowHeight = cell.rowHeight(status)

        // 5.保存计算好的行高
        status.rowHeight = rowHeight
//        print("计算行高 rowHeight: \(rowHeight)")
        
        return rowHeight
    }
    
    // talbeView显示多少条数据
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 如果statuses没有数据,返回0
        return statuses?.count ?? 0
    }
    
    // 返回每个cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 取出对应的模型
        let status = statuses![indexPath.row]
        
        // 去缓存池中查找cell,如果缓存池中找不到可用的cell,会使用注册的cell类型来创建cell(UITableViewCell)
        let cellID = status.cellID()
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! CZStatusCell
        
        // 设置cell的微博模型
        cell.status = status
        
        // 设置微博的正文内容
//        cell.textLabel?.text = status.text
        
        return cell
    }
    
    // MARK: - 懒加载
    /// 显示加载了几条新微博的view
    private lazy var tipLabel: UILabel = {
        // 创建label
        let tipLabel = UILabel(frame: CGRect(x: 0, y: -(self.tipLabelHeight + 20), width: UIScreen.mainScreen().bounds.width, height: self.tipLabelHeight))
        tipLabel.backgroundColor = UIColor.orangeColor()
        tipLabel.textColor = UIColor.whiteColor()
        tipLabel.textAlignment = NSTextAlignment.Center
        tipLabel.font = UIFont.systemFontOfSize(16)
        
        return tipLabel
    }()
}
