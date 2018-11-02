//
//  GiftBannerViewController.swift
//  GiftBanner
//
//  Created by Frank_s on 2018/11/2.
//  Copyright © 2018 Frank_s. All rights reserved.
//

import UIKit

let maxShowingCellCount = 3

class GiftBannerViewController: UIViewController {
    
    // 复用池
    var cellReusePool: [String: NSHashTable<GiftBannerCell>] = [:]
    // 等待队列
    var waitingArr: [GiftModel] = []
    // 展示中cell
    var displayingCellArr: [GiftBannerCell] = []
}

extension GiftBannerViewController {
    
    // 新礼物
    func insert(_ gift: GiftModel) {
        
        let cells: [GiftBannerCell] = displayingCellArr.filter { (cell) -> Bool in
            return cell.giftModel.identifier == gift.identifier
        }
        
        if (cells.count > 0) { // 数字连续递增
            
            if let cell: GiftCell = cells.first as? GiftCell {
                cell.insertNumAnimation(gift)
            }
        } else {
            if (displayingCellArr.count >= maxShowingCellCount) {
                waitingArr.append(gift)
            } else {
                display(with: gift)
            }
        }
    }
    
    // 展示cell
    private func display(with gift: GiftModel) {
        
        var cell: GiftBannerCell! = dequeue("GiftCell")
        if cell == nil {
            cell = GiftCell("GiftCell")
        }
        cell.giftModel = gift
        cell.delegate = self
        
        displayingCellArr.append(cell)
        displayingCellResetFrame()
        view.addSubview(cell)
        
        cell.startDisplayAnimation()
    }
    
    // 重置 frame
    private func displayingCellResetFrame() {
        
        var temCell: GiftBannerCell?
        for cell in displayingCellArr {
            
            var y: CGFloat = 5.0
            if temCell != nil { y = temCell!.frame.maxY + 5.0 }
            if cell.displaying {
                
                if (cell.frame.origin.y != y) {
                    UIView.animate(withDuration: 0.05) {
                        cell.frame.origin.y = y
                    }
                }
            } else {
                cell.frame = CGRect(x: -self.view.bounds.width, y: y, width: self.view.bounds.width, height: 50.0)
            }
            temCell = cell
        }
    }
}

// MAEK: GiftBannerCellDelegate
extension GiftBannerViewController: GiftBannerCellDelegate {
    
    func dismiss(_ bannerCell: GiftBannerCell) {
        
        displayingCellArr.removeAll { (cell) -> Bool in
            return cell.giftModel.identifier == bannerCell.giftModel.identifier
        }
        add(bannerCell)
        bannerCell.removeFromSuperview()
        
        if waitingArr.count > 0 {
            display(with: waitingArr.remove(at: 0))
        }
    }
}

// MARK: 复用池
extension GiftBannerViewController {
    
    /// 复用池存cell
   private func add(_ cell: GiftBannerCell) {
        
        guard cell.reuseIdentifier.count > 0 else { return }
        
        if let set = cellReusePool[cell.reuseIdentifier] {
            set.add(cell)
        } else {
            let set: NSHashTable<GiftBannerCell> = NSHashTable(options: .weakMemory)
            set.add(cell)
            cellReusePool[cell.reuseIdentifier] = set
        }
    }
    
    /// 复用池取cell
    private func dequeue(_ reuseIdentifier: String) -> GiftBannerCell? {
        
        guard reuseIdentifier.count > 0 else { return nil }
        
        var cell: GiftBannerCell? = nil
        if let set = cellReusePool[reuseIdentifier], set.count > 0 {
            
            cell = set.anyObject
            set.remove(cell)
        }
        
        return cell
    }
    /// 清空复用池
    private func clearAll() {
        
        cellReusePool.removeAll()
    }
}
