//
//  RLNodeTopicsList+TableView.swift
//  V2EX
//
//  Created by LLZ on 16/5/12.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

extension RLNodeTopicsList {

    //MARK: -Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:RLNodeTopicCell? = tableView.dequeueReusableCellWithIdentifier("nodeTopicCell") as? RLNodeTopicCell
        if cell == nil {
            cell = (RLNodeTopicCell.instantiateFromNib() as! RLNodeTopicCell)
        }
        if topics.count > indexPath.row {
            cell!.topicModel = self.topics[indexPath.row]
        }
        return cell!
    }
    
    
    //MARK: -UITableViewDelegate
    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return headView.mj_h
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headView
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if topics.count > 0 {
            self.performSegueWithIdentifier("NodeTopicList2TopicContent", sender: topics[indexPath.row])
        }
    }
}

