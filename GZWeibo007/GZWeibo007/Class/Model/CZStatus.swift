//
//  CZStatus.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/20.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

import SDWebImage

// -[__NSCFNumber length]: unrecognized selector sent to instance 0xb0def2ca965ddb43, 看看是不是模型的属性类型出现错误

class CZStatus: NSObject {
    /// 1.定义模型属性
    
    // MARK: - 属性
    /// 创建时间
    var created_at: String?
    
    /// 微博id
    var id: Int = 0
    
    /// 微博正文内容
    var text: String?
    
    /// 来源
    var source: String?
    
    /// 微博的配图 [String: AnyObject], 数组,里面的元素是字典
    var pic_urls: [[String: AnyObject]]? {
        didSet {
            
            let count = pic_urls?.count ?? 0
            if count == 0 {
                // 没有图片
                return
            }

            // 有图片.
            // 创建数组保存转到的NSURL
            storePictureURLs = [NSURL]()
            
            // 遍历所有字典
            for dict in pic_urls! {
                // 取出字典的value,转成NSURL,
                let urlString = dict["thumbnail_pic"] as! String
                
                // 转成NSURL
                let url = NSURL(string: urlString)!
                
                // 添加到storePictureURLs数组
                storePictureURLs?.append(url)
            }
        }
    }
    
    /// 微博配图的NSURL数组.原创微博的配图URL
    var storePictureURLs: [NSURL]?
    
    /// 如果是原创微博显示原创微博的图片,如果是转发微博显示转发微博的图片
    var pictureURLs: [NSURL]? { // 计算性属性
        // 如果是原创微博显示原创微博的图片: storePictureURLs
        // 如果是转发微博显示转发微博的图片: retweeted_status?.storePictureURLs
        return retweeted_status == nil ? storePictureURLs : retweeted_status?.storePictureURLs
    }
    
    /// 转发数
    var reposts_count: Int = 0
    
    /// 评论数
    var comments_count: Int = 0
    
    /// 表态数(赞)
    var attitudes_count: Int = 0
    
    /// 用户模型
    var user: CZUser?
    
    /// 被转发微博模型,只有转发的微博模型才有,原创的微博模型是没有的
    var retweeted_status: CZStatus?
    
    /// 缓存行高, rowHeight == nil 说明没有缓存过行高
    var rowHeight: CGFloat?
    
    /// 返回cell的缓存标识,根据不同模型返回不同的缓存标识
    func cellID() -> String {
        // 判断是原创的模型,还是转发的模型.根据retweeted_status来判断
        // 如果retweeted_status有值,是一个转发微博
        // 如果retweeted_status没有值,是一个原创微博
        return retweeted_status == nil ? CZStatusCellReuseIdentifier.StatusNormalCell.rawValue : CZStatusCellReuseIdentifier.StatusForwardCell.rawValue
    }
    
    // 2.字典转模型
    init(dict: [String: AnyObject]) {
        // 在init之前能赋值,就可以不加?
        super.init()
        
        // 使用KVC来赋值所有属性, KVC是一个方法,方法是只有对象初始化完毕之后才能调用
        setValuesForKeysWithDictionary(dict)
    }
    
    // 3.字典的key在模型中找不到对应的属性,需要实现 forUndefinedKey
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    // setValuesForKeysWithDictionary传入的key有多少个就会调用用多少次,并且传入相应的key和value
    override func setValue(value: AnyObject?, forKey key: String) {
        // 判断如果是user这个key,我们自己来字典转模型,不需要kvc
        if key == "user" {
            // 我们自己来字典转模型
            if let dict = value as? [String: AnyObject] {
                let userModel = CZUser(dict: dict)
                
                // 将模型赋值赋值给user属性
                self.user = userModel
            }
            
            // 一定要记得return,不然会调用父类的setValue,会被覆盖
            return
        }
        
        // 判断key如果是retweeted_status我们将字典转成模型
        if key == "retweeted_status" {
            // 我们自己字典转模型
            if let dict = value as? [String: AnyObject] {
                // 字典转模型
                retweeted_status = CZStatus(dict: dict)
//                print("碰到被转发微博: \(retweeted_status)")
            }
            
            // 一定要记得return,不要被父类的给覆盖了
            return
        }
        
        super.setValue(value, forKey: key)
    }
    
    // 4.实现description属性
    override var description: String {
        let prop = ["created_at", "id", "text", "source", "pic_urls", "reposts_count", "comments_count", "attitudes_count", "user", "retweeted_status"]
        
        // 通过一个数组来生成一个字典,数组中的元素,会成为字典的key,key所对应的value，会从模型中来找对应的属性值
        let dict = dictionaryWithValuesForKeys(prop)
        
        // \n 换行, \t table键
        return "\n\t微博模型: \(dict)"
    }
    
    // MARK: - 加载微博数据
    class func mLoadStatus(since_id: Int, max_id: Int, finished: (statuses: [CZStatus]?, error: NSError?) -> ()) {
        // 3.直接调用网络工具类的方法来加载微博数据
        // 4.准备闭包,尾随闭包
        CZNetworkTool.sharedInstance.loadStatus(since_id, max_id: max_id) { (result, error) -> () in
            // 6.1.判断是否有数据
            if error != nil || result == nil {
                // 没有加载到数据
                // 6.1.1 调用闭包
                finished(statuses: nil, error: error)
                return
            }
            
            // 没有错误,有数据
            // 6.2 字典转模型,判断字典是否有statuses,将statuses的值转成数组,数组里面存放的是字典
            if let array = result?["statuses"] as? [[String: AnyObject]] {
                // 能获取到微博数据
                
                // 6.3 创建一个数组,来存放转好的模型
                var statuses = [CZStatus]()
                
                // 6.4 遍历数组
                // [String: AnyObject] == Dictionary<String, AnyObject>
                for dcit in array {
                    // 6.5 获取到字典,字典转模型
                    let status = CZStatus(dict: dcit)
                    
                    // 6.6 将转好的模型添加到模型数组里面
                    statuses.append(status)
                }
                
                // 6.7 下载图片
                cachedWebImage(statuses, finished: finished)
                // 6.7 所有的模型都转换完成,告诉调用的人有微博模型数据了
//                finished(statuses: statuses, error: nil)
            } else {
                // 6.7
                finished(statuses: nil, error: nil)
            }
        }
    }
    
    /// 类方法只能调用类方法,不能调用对象方法
    /// 缓存图片
    class func cachedWebImage(statuses: [CZStatus], finished: (statuses: [CZStatus]?, error: NSError?) -> ()) {
        // 1. 缓存图片的大小
        var length = 0.0
        
        // 2. 创建任务组
        let group = dispatch_group_create()
        
        // 3. 遍历所有模型
        for status in statuses {
            // 4. 判断模型是否有图片
            guard let urls = status.pictureURLs else {
                // 没有图片要缓存,跳到下一个模型
                continue
            }
            
            // 5. 有图片,遍历缓存所有图片
            // 只有一张图片的时候需要提前知道大小.多张图片的时候可以在显示的时候在下载,可以减少图片的缓存时间
//            for url in urls {
            if urls.count == 1 {
                let url = urls[0]
                //  6. SDWebImageManager缓存图片.是一个异步的任务
                // 6.1 在异步任务之前进入组
                dispatch_group_enter(group)
                // 6.2 执行异步下载图片
                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image, error, _, _, _) -> Void in
                    // 6.3 只要异步任务完成就离开组
                    dispatch_group_leave(group)
                    
                    if error != nil {
                        print("缓存图片失败: \(url)")
                        return
                    }
                    
//                    print("缓存图片成功: \(url)")
                    
                    let data = UIImagePNGRepresentation(image)!
                    length += Double(data.length)
                })
            }
        }
        
        // 7. 在所有的异步任务完成后再来执行
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            print("所有图片下载完成, 大小:\(length / 1024 / 1024) M")
            // 8. 通知别人,获取到所有的微博,调用闭包
            finished(statuses: statuses, error: nil)
        }
    }
}
