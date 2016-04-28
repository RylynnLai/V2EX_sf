//
//  RLTopicList+tableView.swift
//  V2EX
//
//  Created by LLZ on 16/4/26.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

extension RLTopicList {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count ?? 0//假如不存在则返回0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:RLTopicCell? = tableView.dequeueReusableCellWithIdentifier("topicCell") as? RLTopicCell
        if cell == nil {
                        cell = (RLTopicCell.instantiateFromNib() as! RLTopicCell)
        }
        if topics.count > 0 {
//                        cell?.topicModel = (topics[indexPath.row] as! RLTopic)
        }
        return cell!
    }
    //MARK: -UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if pageSelected == .RecentTopics{
            return 105
        } else if pageSelected == .PopTopics {
            return 130
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //        let topicDetallVC = RLTopicDetailVC.init(nibName: "RLTopicDetailVC", bundle: nil)
        if topics.count > 0 {
            //            topicDetallVC.topicModel = topics[indexPath.row] as? RLTopic
        }
        
        self.hidesBottomBarWhenPushed = true
        //        self.navigationController?.pushViewController(topicDetallVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    //MARK: -UIScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.navigationController?.topViewController == self {
            let navBar = self.navigationController?.navigationBar
            if scrollView.contentOffset.y > 0 && navBar?.mj_y == 20 {
                UIView.animateWithDuration(0.5, animations: {
                    navBar?.mj_y = -(navBar?.mj_h)!
                })
            } else if scrollView.contentOffset.y < 0 && navBar?.mj_y < 0 {
                UIView.animateWithDuration(0.5, animations: {
                    navBar?.mj_y = 20.0
                })
            }
        }
    }
}