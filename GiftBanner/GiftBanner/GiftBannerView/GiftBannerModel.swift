//
//  GiftBannerModel.swift
//  GiftBanner
//
//  Created by Frank_s on 2018/11/2.
//  Copyright © 2018 Frank_s. All rights reserved.
//

import Foundation

struct GiftModel {
    
    var sendCount : Int = 0  // 礼物数量
    
    var senderId   : Int = 0  // 送礼者 id
    var senderName : String = ""  // 送礼者 name

    var giftId   : Int = 0  // 礼物 id
    var giftName : String = ""  // 礼物 name
    
    var identifier : String = "" // model id
    
    
    init(json: [String: Any]) {
        
        if let sendCount_ = json["sendCount"] as? Int {
            sendCount = sendCount_
        }
        
        if let senderId_ = json["senderId"] as? Int {
            senderId = senderId_
        }
        
        if let senderName_ = json["senderName"] as? String {
            senderName = senderName_
        }
        
        if let giftId_ = json["giftId"] as? Int {
            giftId = giftId_
        }
        
        if let giftName_ = json["giftName"] as? String {
            giftName = giftName_
        }
        
        identifier = "\(senderId)-\(giftId)"
    }
}
