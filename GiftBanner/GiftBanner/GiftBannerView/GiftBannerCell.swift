//
//  GiftBannerCell.swift
//  GiftBanner
//
//  Created by Frank_s on 2018/11/2.
//  Copyright © 2018 Frank_s. All rights reserved.
//

import Foundation
import UIKit

enum GiftBannerCellAnimationState {
    
    case end
    case start
}


protocol GiftBannerCellDelegate: AnyObject {
    
    func dismiss(_ bannerCell: GiftBannerCell)
}

class GiftBannerCell : UIView {
    
    var giftModel: GiftModel!
    
    weak var delegate: GiftBannerCellDelegate?
    /// cell重用标识
    var reuseIdentifier: String
    /// cell 是否展示中
    var displaying: Bool = false
    /// cell 动画状态
    var animationState: GiftBannerCellAnimationState = .end
    
    // MARK: init
    
    required init(_ reuseIdentifier: String) {
        self.reuseIdentifier = reuseIdentifier
        super.init(frame: .zero)
    }
    
    required init(frame: CGRect, reuseIdentifier: String) {
        self.reuseIdentifier = reuseIdentifier
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error: ..................")
    }
    
    /// 开启展示动画
    func startDisplayAnimation() {
        fatalError("Error: 须子类实现..........")
    }
}

extension GiftBannerCell {
    
    func animationForDisplay() {
        
        self.alpha = 1.0
        self.frame.origin.x = 0.0
    }
    
    func animationForDismiss() {
        
        self.alpha = 0.0
        self.frame.origin.y += 10.0
    }
}




