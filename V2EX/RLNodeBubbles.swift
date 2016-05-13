//
//  RLNodeBubbles.swift
//  V2EX
//
//  Created by LLZ on 16/5/9.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

class RLNodeBubbles: UIViewController, BubblesViewDelegate {

    lazy var dismissBtn:UIButton = {
        let btn = UIButton.init(frame: CGRectMake(20, 20, 40, 40))
        btn.alpha = 0.5
        btn.backgroundColor = V2EXGray
        btn.setTitle("返回", forState: .Normal)
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(RLNodeBubbles.dismiss), forControlEvents: .TouchUpInside)
        return btn
    }()
    
    private lazy var bubblesView:RLBubblesView = {
        var bView = RLBubblesView.init(frame: UIScreen.mainScreen().bounds)
        bView.Bdelegate = self
        bView.nodeBtnAction = {[weak self] (nodeModel) -> Void in
            if let strongSelf = self {
                strongSelf.performSegueWithIdentifier("NodeBubbles2NodeTopicList", sender: nodeModel)//执行segue线
            }
        }
        return bView
    }()
    
    private lazy var AIV: UIActivityIndicatorView = {
        let aviView = UIActivityIndicatorView.init(frame: CGRectMake(0, 0, 40, 40))
        aviView.center = self.view.center
        return aviView
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(bubblesView)
        self.view.addSubview(dismissBtn)
        self.view.addSubview(AIV)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.hidden = true
        loadData()
    }

    private func loadData()  {
        if Node.popularNode().count > 100 && self.bubblesView.nodeModels?.count <= 0 {
            AIV.startAnimating()
            self.bubblesView.nodeModels = NSSet.init(array: Node.popularNode())
            AIV.stopAnimating()
        }
        
        RLNodesHelper.shareNodesHelper.nodesWithCompletion { [weak self] (nodes) in
            if let strongSelf = self {
                if strongSelf.bubblesView.nodeModels == nil || strongSelf.bubblesView.nodeModels?.count < Node.popularNode().count {//如果目前显示的bubbles较少，则更新
                    strongSelf.bubblesView.nodeModels = NSSet.init(array: Node.allNodes())
                }
                strongSelf.AIV.stopAnimating()
            }
        }
    }
    
    
    @objc private func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
//MARK: -segue
extension RLNodeBubbles {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NodeBubbles2NodeTopicList" {
            if let vc = segue.destinationViewController as? RLNodeTopicsList {
                vc.nodeModel = (sender as! Node)
            }
        }
    }
}
//MARK: -BubblesViewDelegate
extension RLNodeBubbles {
    func didStopSlipAnimation() {
        UIView.animateWithDuration(0.5) {
            self.dismissBtn.alpha = 0.7
        }
    }
    
    func willStartSlipAnimation() {
        UIView.animateWithDuration(0.5) { 
            self.dismissBtn.alpha = 0.1
        }
    }
}