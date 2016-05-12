//
//  RLNodeBubbles.swift
//  V2EX
//
//  Created by LLZ on 16/5/9.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit
import Alamofire

class RLNodeBubbles: UIViewController, BubblesViewDelegate {

    lazy var dismissBtn:UIButton = {
        let btn = UIButton.init(frame: CGRectMake(20, 20, 40, 40))
        btn.backgroundColor = V2EXGray
        btn.setTitle("返回", forState: .Normal)
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(RLNodeBubbles.dismiss), forControlEvents: .TouchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        if let bubblesView = self.view as? RLBubblesView {
            bubblesView.Bdelegate = self
            bubblesView.nodeBtnAction = {[weak self] (nodeModel)->Void in
                if let strongSelf = self {
                    strongSelf.performSegueWithIdentifier("NodeBubbles2NodeTopicList", sender: nodeModel)//执行segue线
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        self.view.addSubview(dismissBtn)
    }

    private func loadData()  {
        Alamofire.request(.GET, mainURLStr + "/api/nodes/all.json").responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error 获取节点数据失败: \(response.result.error)")
                return
            }
            if let responseJSON = response.result.value as? [NSDictionary]{
                let nodes = Node.createNodesArray(fromKeyValuesArray: responseJSON)
                (self.view as! RLBubblesView).nodeModels = NSSet.init(array: nodes)
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
        UIView.animateWithDuration(0.2) {
            self.dismissBtn.alpha = 1
        }
    }
    
    func willStartSlipAnimation() {
        UIView.animateWithDuration(0.5) { 
            self.dismissBtn.alpha = 0
        }
    }
}