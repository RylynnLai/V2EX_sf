//
//  RLTopicsTVC.swift
//  V2EX
//
//  Created by LLZ on 16/3/28.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

public enum RLPageSelected {
    case RecentTopics
    case PopTopics
}

//用全局变量代替宏定义
let tagW = screenW * 0.4
let tipicesNumOfEachPage = 20

class RLTopicList: UITableViewController {

    private lazy var recentBtn:UIButton = {
        let btn = UIButton.init(type: .System)
        btn.frame = CGRectMake(0, 0, tagW * 0.5, 30)
        btn.setTitle("最近", forState: .Normal)
        btn.setBackgroundImage(UIImage.init(named: "tagBG"), forState: .Selected)
        btn.addTarget(self, action: #selector(RLTopicList.tagClick(_:)), forControlEvents: .TouchUpInside)
        return btn
    }()
    private lazy var popBtn:UIButton = {
        let btn = UIButton.init(type: .System)
        btn.frame = CGRectMake(tagW * 0.5 - 1, 0, tagW * 0.5, 30)
        btn.setTitle("最热", forState: .Normal)
        btn.setBackgroundImage(UIImage.init(named: "tagBG"), forState: .Selected)
        btn.addTarget(self, action: #selector(RLTopicList.tagClick(_:)), forControlEvents: .TouchUpInside)
        return btn
    }()
    
    private lazy var header:MJRefreshNormalHeader = {
        let refleshHeader = MJRefreshNormalHeader()
        refleshHeader.setRefreshingTarget(self, refreshingAction: #selector(RLTopicList.refreshData))
        return refleshHeader
    }()
    private lazy var footer:MJRefreshAutoNormalFooter = {
        let refleshFooter = MJRefreshAutoNormalFooter()
        refleshFooter.setRefreshingTarget(self, refreshingAction: #selector(RLTopicList.loadMore))
        refleshFooter.refreshingTitleHidden = true
        return refleshFooter
    }()
    
    /**保存数据模型数组*/
    lazy var topics = {return [Topic]()}()
    var currentPageIdx:NSInteger?//当前加载到的页码,20条话题一页(由服务器决定)
    var pageSelected:RLPageSelected = .RecentTopics//最新or最热
    //MARK: -生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        tagClick(recentBtn)//第一次启动时选中最新,需要放在添加header和footer前,防止重复刷新
        //默认会执行一次refreshData()
        self.tableView.mj_header = header
        //默认会执行一次loadMore()
        self.tableView.mj_footer = footer
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let nav = self.splitViewController?.viewControllers.last as? UINavigationController {
            UIView.animateWithDuration(0.2, animations: {
                nav.navigationBar.mj_y = 20.0
            })
        }
    }

    //MARK: - action方法

    //因为selector是OC中运行时的产物，Swift是静态语言，虽然继承自NSObject的类默认对ObjC运行时是可见的，但如果方法是由private关键字修饰的，则方法默认情况下对ObjC运行时并不是可见的。如果我们的类是纯Swift类，而不是继承自NSObject，则不管方法是private还是internal或public，如果要用在Selector中，都需要加上@objc修饰符。
    @objc private func tagClick(btn:UIButton) {
        if btn == recentBtn {
            self.tableView.mj_footer = footer
            
            recentBtn.selected = true
            popBtn.selected = false
            pageSelected = .RecentTopics
        } else {
            self.tableView.mj_footer = nil
            
            popBtn.selected = true
            recentBtn.selected = false
            pageSelected = .PopTopics
        }
        header.beginRefreshing()
    }
    
}
//MARK: -segue
extension RLTopicList {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TopicList2TopicContent" {
            if let topicContent = (segue.destinationViewController as? UINavigationController)?.topViewController as? RLTopicContent {
                topicContent.topicModel = sender as? Topic
            }
        }
    }
}
//MARK: - UI
extension RLTopicList {
    private func initUI() {
        let tagView = UIView.init(frame: CGRectMake(0, 0, tagW, 30))
        tagView.layer.cornerRadius = 10
        tagView.layer.masksToBounds = true
        tagView.layer.borderWidth = 1
        tagView.layer.borderColor = V2EXGray.CGColor
        tagView.tintColor = V2EXGray
        tagView.addSubview(recentBtn)
        tagView.addSubview(popBtn)
        self.navigationItem.titleView = tagView
        
        //设置返回按钮
        let backBarButtonItem = UIBarButtonItem.init()
        backBarButtonItem.title = ""
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
}
//MARK: -加载数据
extension RLTopicList {
    @objc private func refreshData() {
        if header.state == .Refreshing {
            RLTopicsHelper.shareTopicsHelper.currentPageIdx = 1
            self.topics.removeAll()
            loadData()
        }
    }
    @objc private func loadMore() {
        if pageSelected == .PopTopics {
            dispatch_async(dispatch_get_main_queue(), {
                [weak self] in
                if let strongSelf = self {
                    strongSelf.tableView.mj_footer.endRefreshing()
                }
            })
        }
        if footer.state == .Refreshing {
            let pageIdx = RLTopicsHelper.shareTopicsHelper.currentPageIdx
            RLTopicsHelper.shareTopicsHelper.currentPageIdx = pageIdx + 1
            loadData()
        }
    }
    private func loadData() {
        //只有处于刷新状态才请求网络,防止重复请求
        if header.state == .Refreshing || footer.state == .Refreshing {
            RLTopicsHelper.shareTopicsHelper.topicsWithCompletion({ [weak self]  (topics) in
                if let strongSelf = self {
                    strongSelf.topics = topics!
                    //在主线程刷新UI
                    dispatch_async(dispatch_get_main_queue(), {
                        strongSelf.tableView.reloadData()
                        strongSelf.header.endRefreshing()
                        strongSelf.footer.endRefreshing()
                    })
                }
                }, option: pageSelected)
        }
    }
}
