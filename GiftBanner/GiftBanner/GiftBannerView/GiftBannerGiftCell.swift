//
//  GiftBannerGiftCell.swift
//  GiftBanner
//
//  Created by Frank_s on 2018/11/2.
//  Copyright © 2018 Frank_s. All rights reserved.
//

import Foundation
import UIKit

class GiftCell: GiftBannerCell {
    
    override var giftModel: GiftModel! {
        willSet {
            senderNameLabel.text = newValue.senderName
            giftNameLabel.text = "送出  " + newValue.giftName
        }
    }
    
    var bgImageView: UIImageView!
    var giftImageView: UIImageView!
    var senderNameLabel: UILabel!
    var giftNameLabel: UILabel!
    var numLabel: UILabel!
    
    var waitingGift: GiftModel?
    
    var count: Int = 0 // 记录递增数量
    
    required init(_ reuseIdentifier: String) {
        super.init(reuseIdentifier)
        
        bgImageView = UIImageView()
        bgImageView.image = UIImage(named: "bg") // 160 x 35
        self.addSubview(bgImageView)
        
        giftImageView = UIImageView()
        giftImageView.image = UIImage(named: "rocket")
        self.addSubview(giftImageView)
        
        senderNameLabel = UILabel()
        senderNameLabel.textColor = .white
        senderNameLabel.font = UIFont.systemFont(ofSize: 14.0)
        self.addSubview(senderNameLabel)
        
        giftNameLabel = UILabel()
        giftNameLabel.textColor = .white
        giftNameLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.addSubview(giftNameLabel)
        
        numLabel = UILabel()
        numLabel.textColor = .orange
        numLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        numLabel.alpha = 0.0
        self.addSubview(numLabel)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(frame: CGRect, reuseIdentifier: String) {
        super.init(frame: frame, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        bgImageView.frame = CGRect(x: 0.0, y: 10.0,
                                   width: self.bounds.width,
                                   height: self.bounds.height-10.0)
        
        giftImageView.frame = CGRect(x: self.bounds.width-55.0, y: 0.0,
                                     width: self.bounds.height-10.0,
                                     height: self.bounds.height-10.0)
        
        senderNameLabel.frame = CGRect(x: 25.0, y: 10.0,
                                       width: self.bounds.width-90.0,
                                       height: (self.bounds.height-10.0)*0.5)
        
        giftNameLabel.frame = CGRect(x: 25.0,
                                     y: senderNameLabel.frame.maxY,
                                     width: self.bounds.width-90.0,
                                     height: (self.bounds.height-10.0)*0.5)
        
    }
    
    // 数字递增动画
    private func startNumAnimation(_ sendCount: Int, befCount: Int, completion: @escaping () -> Void) {
        
        count += 1
        
        numLabel.text = "x\(self.count)"
        let size = numLabel.sizeThatFits(.zero)
        if numLabel.bounds.width != size.width || numLabel.bounds.height != size.height {
            numLabel.frame = CGRect(x: self.bounds.width + 5.0, y: self.bounds.height - size.height, width: size.width, height: size.height)
        }
        
        if numLabel.transform.isIdentity {
            numLabel.layer.removeAllAnimations()
        }
        numLabel.transform = .identity
        
        UIView.animate(withDuration: 0.15,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveLinear,
                       animations: {
                        self.numLabel.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }) { (_) in
            
            UIView.animate(withDuration: 0.1, animations: {
                self.numLabel.transform = .identity
            })
            
            if sendCount > 1 {
                self.startNumAnimation(sendCount - 1, befCount: self.count, completion: completion)
            } else {
                self.animationState = .end
                completion()
            }
        }
    }
    
    // cell 展示动画
    override func startDisplayAnimation() {
      
        self.displaying = true
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseIn,
                       animations: { self.animationForDisplay() })
        { _ in
            
            self.numLabel.alpha = 1.0
            self.insertNumAnimation(self.giftModel)
        }
    }
    
    // 插入数字动画
    func insertNumAnimation(_ gift: GiftModel) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(dismissAnimation), object: nil)
        
        if (self.animationState == .start) {
            if waitingGift != nil {
                waitingGift!.sendCount = gift.sendCount + waitingGift!.sendCount
            } else {
                waitingGift = gift;
            }
        } else {
            self.animationState = .start
            startNumAnimation(giftModel.sendCount, befCount: count) {
                self.numAnimationEnd()
            }
        }
    }
    
    // 一组数字递增动画完成
    private func numAnimationEnd() {
        if let tem = waitingGift {
            insertNumAnimation(tem)
        } else {
            perform(#selector(dismissAnimation), with: nil, afterDelay: 5.0)
        }
    }
    
    // 结束
    @objc private func dismissAnimation() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseIn,
                       animations: { self.animationForDismiss() })
        { _ in
            self.displaying = false
            self.count = 0
            self.alpha = 0.0
            self.delegate?.dismiss(self)
        }
    }
}
