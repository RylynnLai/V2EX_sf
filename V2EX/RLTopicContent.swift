//
//  RLTopicContent.swift
//  V2EX
//
//  Created by LLZ on 16/4/29.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

class RLTopicContent: UIViewController {
    var topicModel:Topic?
    
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
        /*这里规则是
         *检查数据是否完整,完整就直接显示帖子内容,不重新请求;不完整就发起网络请求,并更新内存缓存保存新的数据
         *用户可以手动下拉刷新话题列表刷新或下拉刷新帖子刷新,需要更新缓存数据
         */
        if topicModel?.content_rendered == nil {
            loadingAIV.startAnimating()
            RLTopicsHelper.shareTopicsHelper.topicWithTopicID((topicModel?.id)!, completion: {[weak self] (topic) in
                if let strongSelf = self {
                    strongSelf.topicModel = topic
                    strongSelf.initData()
                }
                })
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animateWithDuration(0.1, animations: {
            [weak self] in
            if let strongSelf = self {
                strongSelf.navigationController?.navigationBar.mj_y = 20;
            }
            })
    }
    
    
    //MARK: -私有方法
    private func initUI() {
        self.view.addSubview(self.contentWbV)
        loadingAIV.frame = CGRectMake(self.view.mj_w * 0.5, self.view.mj_h * 0.5, 20, 20)
        loadingAIV.activityIndicatorViewStyle = .Gray
        loadingAIV.hidesWhenStopped = true
    }
    
    private func initData() {
        //导航栏标题
        self.title = topicModel!.title
        //帖子内容
        let htmlStr = String.HTMLstringWithBody(topicModel!.content_rendered ?? "")
        contentWbV.loadHTMLString(htmlStr, baseURL: nil)
        //头像
        let iconURL = NSURL.init(string: "https:\(topicModel!.member!.avatar_normal!)")
        authorBtn.sd_setImageWithURL(iconURL, forState: .Normal, placeholderImage: UIImage.init(named: "blank"))
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
    
    private func loadRepliesData() {
        
    }
    
    private func addRepliesList()  {
        
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
            webView.mj_h = webView.scrollView.contentSize.height + 64
            webView.scrollView.scrollEnabled = false
            let scrollView = self.view as! UIScrollView
            scrollView.contentSize = CGSizeMake(webView.mj_w, webView.mj_h + 100)
            //MJRefresh(加载评论)
            let footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: Selector(loadRepliesData()))
            footer.refreshingTitleHidden = true
            footer.stateLabel.textColor = UIColor.lightGrayColor()
            footer.stateLabel.alpha = 0.4
            footer.setTitle("点击或上拉显示评论列表", forState: .Idle)
            scrollView.mj_footer = footer
        }
    }
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //当前为最顶上控制器才进行下面判断是否隐藏导航条
        if self.navigationController?.topViewController == self {
            let navBar = self.navigationController?.navigationBar
            if scrollView.contentOffset.y > 0 && (navBar?.mj_y == 20) {
                UIView.animateWithDuration(0.5, animations: {
                    (navBar?.mj_y = -(navBar?.mj_h)!)!
                })
            } else if scrollView.contentOffset.y < 0 && (navBar?.mj_y < 0) {
                UIView.animateWithDuration(0.5, animations: {
                    navBar?.mj_y = 20.0
                })
            }
            
        }
    }


}
