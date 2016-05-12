//
//  RLTopicList+tableView.swift
//  V2EX
//
//  Created by LLZ on 16/4/26.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

extension RLTopicList {
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
            cell!.topicModel = topics[indexPath.row] 
        }
        return cell!
    }
    //MARK: -UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard topics.count >= indexPath.row else { return 0 }
        if (topics[indexPath.row].content != nil) {
            return 130
        } else {
            return 105
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if topics.count > 0 {
            self.performSegueWithIdentifier("TopicList2TopicContent", sender: topics[indexPath.row])
        }
    }
}