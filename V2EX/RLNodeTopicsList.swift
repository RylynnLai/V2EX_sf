//
//  RLNodeTopicsList.swift
//  V2EX
//
//  Created by LLZ on 16/3/22.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

class RLNodeTopicsList: UITableViewController {
    var nodeModel:Node?
    // 顶部刷新
    
    private lazy var header:MJRefreshNormalHeader = {
        let refleshHeader = MJRefreshNormalHeader()
        refleshHeader.setRefreshingTarget(self, refreshingAction: #selector(RLNodeTopicsList.refreshData))
        return refleshHeader
    }()
    private lazy var footer:MJRefreshBackNormalFooter = {
        let refleshFooter = MJRefreshBackNormalFooter()
        refleshFooter.setRefreshingTarget(self, refreshingAction: #selector(RLNodeTopicsList.loadMore))
        refleshFooter.setTitle("再拉也没用,Livid只给了我10条数据", forState: .Refreshing)
        refleshFooter.setTitle("", forState: .Idle)
        return refleshFooter
    }()
    
    //懒加载
    lazy var topics = {return [Topic]()}()
    lazy var headView:RLNodesHeadView = {
        return RLNodesHeadView.instantiateFromNib() as! RLNodesHeadView
    }()
    
    //MARK: -生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        self.tableView.separatorStyle = .None;
        
        //MJRefresh
        self.tableView.mj_header = header
        self.tableView.mj_footer = footer
        
        loadNodeData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //只能放在这,透视图拿到nodemodel数据后就能确定高度,自适应高度
        self.tableView.tableHeaderView = self.headView
        
    }
  
    //MARK: -加载数据
    //下拉刷新
    @objc private func refreshData() {
        if nodeModel != nil {
            RLTopicsHelper.shareTopicsHelper.nodeTopicsWithNodeID(nodeModel!.id!, completion: { [weak self] (topics) in
                if let strongSelf = self, let topicModels = topics {
                    strongSelf.topics = topicModels
                    strongSelf.tableView.mj_header.endRefreshing()
                    strongSelf.tableView.reloadData()
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
    //获取完整的节点数据
    private func loadNodeData() {
        if nodeModel != nil {
            self.title = nodeModel!.title
            self.headView.nodeModel = nodeModel
            
            RLNodesHelper.shareNodesHelper.nodeWithNodeID(nodeModel!.id!, completion: { [weak self] (node) in
                if let strongSelf = self {
                    strongSelf.nodeModel = node
                    strongSelf.headView.nodeModel = strongSelf.nodeModel
                    strongSelf.tableView.mj_header.beginRefreshing()
                }
            })
        }
    }
}

//MARK: -segue
extension RLNodeTopicsList {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NodeTopicList2TopicContent" {
            if let topicContent = (segue.destinationViewController as? UINavigationController)?.topViewController as? RLTopicContent {
                topicContent.topicModel = sender as? Topic
            }
        }
    }
}
