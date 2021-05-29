//
//  CZUser.swift
//  GZWeibo007
//
//  Created by Apple on 15/12/20.
//  Copyright © 2015年 Apple. All rights reserved.
//

import UIKit

// private 修饰的属性,KVC找不到

class CZUser: NSObject {

    // MARK: - 属性
    
    /// 用户UID
    var id: Int64 = 0
    
    /// 用户昵称
    var screen_name: String?
    
    /// 用户头像地址（中图），50×50像素
    var profile_image_url: String?
    
    /// 认证类型, 没有认证:-1   认证用户:0  企业认证:2,3,5  达人:220
    var verified_type: Int = -1 {
        didSet {
            // 根据不同类型设置不同的认证图片
            switch verified_type {
            case 0:
                verifiedImage = UIImage(named: "avatar_vip")
            case 2,3,5:
                verifiedImage = UIImage(named: "avatar_enterprise_vip")
            case 220:
                verifiedImage = UIImage(named: "avatar_grassroot")
            default:
                verifiedImage = nil
            }
        }
    }
    
    /// 添加 认证类型对应的 图片,外部直接访问 verifiedImage
    var verifiedImage: UIImage?
    
    /// 会员等级 1 - 6
    var mbrank: Int = 0 {
        didSet {
            if mbrank > 0 && mbrank <= 6 {
                mbrankImage = UIImage(named: "common_icon_membership_level\(mbrank)")
            } else {
                // 清空图片,防止cell复用
                mbrankImage = nil
            }
        }
    }
    
    /// 添加 会员等级对应的图片, 外部直接访问 mbrankImage
    var mbrankImage: UIImage?
    
    /// 字典转模型
    init(dict: [String: AnyObject]) {
        super.init()
        
        // KVC赋值
        setValuesForKeysWithDictionary(dict)
    }
    
    // 字典的key在模型中没有对应的属性
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
    
    // 打印
    override var description: String {
        let prop = ["id", "screen_name", "profile_image_url", "verified_type", "mbrank"]
        
        let dict = dictionaryWithValuesForKeys(prop)
        return "\n\t\t用户模型:\(dict)"
    }
}
