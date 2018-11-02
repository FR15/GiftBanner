//
//  ViewController.swift
//  GiftBanner
//
//  Created by Frank_s on 2018/11/2.
//  Copyright © 2018 Frank_s. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    func json() -> [String: Any] {
        
        // 1 - 20
        let sendCount: Int = Int(arc4random() % 20 + 1)
        // 1001 - 1010
        let senderId: Int = Int(arc4random() % 10 + 1) + 1000
        let senderName: String = "XXXXXXXXX"
        // 101 - 110
        let giftId: Int = Int(arc4random() % 10 + 1) + 100
        let giftName: String = "礼"
        
        return  ["sendCount": sendCount,
                 "senderId": senderId,
                 "senderName": senderName,
                 "giftId": giftId,
                 "giftName": giftName]
    }
    
    weak var bannerViewController: GiftBannerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let v = GiftBannerViewController()
        addChild(v)
        bannerViewController = v
        
        bannerViewController.view.frame = CGRect(x: 0.0, y: 100.0,
                              width: view.bounds.width * 0.6,
                              height: view.bounds.height - 300.0)
        view.addSubview(bannerViewController.view)
    }
    
    
    @IBAction func addOne(_ sender: Any) {
        
        bannerViewController.insert(GiftModel(json: json()))
    }
    
}


