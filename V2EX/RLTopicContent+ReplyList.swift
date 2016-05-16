//
//  RLTopicContent+ReplyList.swift
//  V2EX
//
//  Created by LLZ on 16/5/13.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

extension RLTopicContent {
    // MARK: - Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyModels.count ?? 0//假如不存在则返回0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:RLReplyCell? = tableView.dequeueReusableCellWithIdentifier("replyCell") as? RLReplyCell
        if cell == nil {
            cell = (RLReplyCell.instantiateFromNib() as! RLReplyCell)
        }
        if replyModels.count > indexPath.row {
            let replyModel = replyModels[indexPath.row]
            replyModel.floor = indexPath.row
            cell?.replyModel = replyModel
        }
        return cell!
    }
    //MARK: -UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard replyModels.count >= indexPath.row else { return 0 }
        // 创建一个临时的cell(目的:传递模型数据,计算cell所有子控件的frame,进而计算cell的高度)
        if tempCell == nil {
            tempCell = tableView.dequeueReusableCellWithIdentifier("replyCell") as? RLReplyCell
            if tempCell == nil {
                tempCell = (RLReplyCell.instantiateFromNib() as! RLReplyCell)
            }
        }
        tempCell?.replyModel = replyModels[indexPath.row]
        let height = tempCell?.cellHeight() ?? 0
        replyListHeight += height
        return height
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //splitViewController下面有两个NavigationController(master,detail)
        if let nav = self.splitViewController?.viewControllers.last as? UINavigationController {
            if scrollView == self.view {
                let navBar = nav.navigationBar
                if scrollView.contentOffset.y > 0 && (navBar.mj_y == 20) {
                    UIView.animateWithDuration(0.5, animations: {
                        navBar.mj_y = -navBar.mj_h
                    })
                } else if scrollView.contentOffset.y < 0 && (navBar.mj_y < 0) {
                    UIView.animateWithDuration(0.2, animations: {
                        navBar.mj_y = 20.0
                    })
                }
                if scrollView.contentOffset.y <= contentWbV.mj_h {
                    replyList.scrollEnabled = false
                } else {
                    replyList.scrollEnabled = true
                }
            }
        }
        
    }
}



