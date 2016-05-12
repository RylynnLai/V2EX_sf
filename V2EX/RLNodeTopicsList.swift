//
//  RLNodeTopicsList.swift
//  V2EX
//
//  Created by LLZ on 16/3/22.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit
import Alamofire

class RLNodeTopicsList: UITableViewController {
    var nodeModel:Node?
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshBackNormalFooter()
    //懒加载
    lazy var topics = {return [Topic]()}()
    lazy var headView:RLNodesHeadView = {
        return RLNodesHeadView.instantiateFromNib() as! RLNodesHeadView
    }()
    
    //MARK: -生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        
        //MJRefresh
        header.setRefreshingTarget(self, refreshingAction: #selector(RLNodeTopicsList.refreshData))
        self.tableView.mj_header = header
        footer.setRefreshingTarget(self, refreshingAction: #selector(RLNodeTopicsList.loadMore))
        footer.setTitle("再拉也没用,Livid只给了我10条数据", forState: .Refreshing)
        self.tableView.mj_footer = footer
        
        loadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //只能放在这,配合table的头视图代理方法,自适应高度
        self.tableView.tableHeaderView = self.headView
    }
  
    //MARK: -加载数据
    //下拉刷新
    @objc private func refreshData() {
        if nodeModel != nil {
            let path = mainURLStr + "/api/topics/show.json?node_id=\(nodeModel!.id!)"
            Alamofire.request(.GET, path).responseJSON(completionHandler: { [weak self] (response) in
                guard response.result.isSuccess else {
                    print("Error 获取节点话题数据失败: \(response.result.error)")
                    self!.tableView.mj_header.endRefreshing()
                    return
                }
                if let responseJSON = response.result.value as? [AnyObject] {
                    if let strongSelf = self {
                        strongSelf.topics = Topic.createTopicsArray(fromKeyValuesArray: responseJSON)
                        strongSelf.tableView.mj_header.endRefreshing()
                        strongSelf.tableView.reloadData()
                    }
                }
            })
        }
    }
    //上拉加载更多
    @objc private func loadMore() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [weak self] () -> Void in
            if let strongSelf = self {
                strongSelf.tableView.mj_footer.endRefreshing()
            }
        }
    }
    private func loadData() {
        if nodeModel != nil {
            self.title = nodeModel!.title
            self.headView.nodeModel = nodeModel
            //获取完整的节点数据
            let path = mainURLStr + "/api/nodes/show.json?id=\(nodeModel!.id!)"
            Alamofire.request(.GET, path).responseJSON { [weak self] (response) in
                guard response.result.isSuccess else {
                    print("Error 获取节点数据失败: \(response.result.error)")
                    return
                }
                if let responseJSON = response.result.value {
                    if let strongSelf = self {
                        strongSelf.nodeModel = Node.createNode(fromKeyValues: responseJSON)
                        strongSelf.headView.nodeModel = strongSelf.nodeModel
                        strongSelf.tableView.mj_header.beginRefreshing()
                    }
                }
            }
        }
    }
}

//MARK: -segue
extension RLNodeTopicsList {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NodeTopicList2TopicContent" {
            if let topicContent = segue.destinationViewController as? RLTopicContent {
                topicContent.topicModel = sender as? Topic
            }
        }
    }
}
