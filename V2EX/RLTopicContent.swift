//
//  RLTopicContent.swift
//  V2EX
//
//  Created by LLZ on 16/4/29.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

class RLTopicContent: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var replyListHeight:CGFloat = 0.0
    var tempCell:RLReplyCell? = nil
    var topicModel:Topic?
    lazy var replyModels:[Reply] = [Reply]()
    lazy var replyList:UITableView = {
        let list = UITableView()
        list.bounces = false
        list.alpha = 0.0
        list.dataSource = self
        list.delegate = self
        return list
    }()
    private lazy var footer:MJRefreshAutoNormalFooter = {
        let refleshFooter = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(RLTopicContent.loadRepliesData))
        refleshFooter.refreshingTitleHidden = true
        refleshFooter.stateLabel.textColor = UIColor.lightGrayColor()
        refleshFooter.stateLabel.alpha = 0.4
        refleshFooter.setTitle("点击或上拉显示评论列表", forState: .Idle)
        return refleshFooter
    }()
    
    
    @IBOutlet weak var loadingAIV: UIActivityIndicatorView!
    @IBOutlet weak var authorLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var createdTimeLable: UILabel!
    @IBOutlet weak var authorBtn: UIButton!
    @IBOutlet weak var replieNumLable: UILabel!
    @IBOutlet weak var contentWbV: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        initData()
        
        self.replyList.estimatedRowHeight = 100;
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animateWithDuration(0.1, animations: { [weak self] in
            if let strongSelf = self {
                strongSelf.navigationController?.navigationBar.mj_y = 20;
            }
        })
    }
    
    
    //MARK: -私有方法
    private func initUI() {
        guard (topicModel != nil) else { return }
        //导航栏标题
        self.title = topicModel!.title
        //帖子内容
        let htmlStr = String.HTMLstringWithBody(topicModel!.content_rendered ?? "")
        contentWbV.loadHTMLString(htmlStr, baseURL: nil)
        //头像
        let iconURL = NSURL.init(string: "https:\(topicModel!.member!.avatar_normal!)")
        authorBtn.sd_setBackgroundImageWithURL(iconURL, forState: .Normal, placeholderImage: UIImage.init(named: "blank"))
        //标题
        titleLable.text = topicModel!.title
        titleLable.adjustsFontSizeToFitWidth = true//固定lable大小,内容自适应,还有个固定字体大小,lable自适应的方法sizeToFit
        //作者名称
        authorLable.text = "\(topicModel!.member!.username!) ●"
        //创建时间
        if topicModel!.createdTime != nil {
            createdTimeLable.text = "\(topicModel!.createdTime!) ●"
        } else {
            createdTimeLable.text = String.creatTimeByTimeIntervalSince1970(Double(topicModel!.created!))
        }
        //回复个数
        replieNumLable.text = "\(topicModel!.replies!)个回复"
    }
    
    private func initData() {
        /*这里规则是
         *检查数据是否完整,完整就直接显示帖子内容,不重新请求;不完整就发起网络请求,并更新内存缓存保存新的数据
         *用户可以手动下拉刷新话题列表刷新或下拉刷新帖子刷新,需要更新缓存数据
         */
        guard topicModel != nil else { return }
        if topicModel!.content_rendered == nil {
            loadingAIV.startAnimating()
            RLTopicsHelper.shareTopicsHelper.topicWithTopicID(topicModel!.id!, completion: {[weak self] (topic) in
                if let strongSelf = self {
                    strongSelf.topicModel = topic
                    strongSelf.initUI()
                }
            })
        }
    }
    
    @objc private func loadRepliesData() {
        if let topic = topicModel {
            RLTopicsHelper.shareTopicsHelper.repliesWithTopicID(topic.id!, completion: { [weak self] (replies) in
                if let strongSelf = self {
                    strongSelf.replyModels = replies
                    if replies.count > 0 {
                        strongSelf.replyList.alpha = 1.0
                        strongSelf.replyList.mj_h = screenH - 20
                        let scrollView = strongSelf.view as! UIScrollView
                        scrollView.contentSize = CGSizeMake(strongSelf.contentWbV.frame.maxX, strongSelf.contentWbV.mj_h + 64 + screenH)
                        scrollView.setContentOffset(CGPointMake(0, strongSelf.contentWbV.mj_h + 64), animated: true)
                        
                        strongSelf.replyList.reloadData()
                        strongSelf.footer.setTitle("点击或上拉刷新评论列表", forState: .Idle)
                    } else {
                        strongSelf.footer.setTitle("目前还没有人发表评论", forState: .Idle)
                    }
                    strongSelf.footer.endRefreshing()
                }
            })
        }
    }
    
    //MARK: - UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        loadingAIV.startAnimating()
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        if webView.loading {
            return
        } else {
            loadingAIV.stopAnimating()
            //根据内容改变webView的高度(有些奇怪，约束不起作用了)，webView不可以滑动
            webView.mj_h = webView.scrollView.contentSize.height
            webView.scrollView.scrollEnabled = false
            //本控制器的scrollView可以滑动，改变contentSize
            let scrollView = self.view as! UIScrollView
            scrollView.contentSize = CGSizeMake(webView.frame.maxX, webView.mj_h + 64)//加上导航栏高度+评论列表初始高度
            
            replyList.frame = CGRectMake(0, webView.frame.maxY, webView.frame.maxX, 20)
            
            scrollView.addSubview(replyList)
            
            //MJRefresh(加载评论,第一次添加footer默认会拉一次数据)
            scrollView.mj_footer = footer
        }
    }
  
}
