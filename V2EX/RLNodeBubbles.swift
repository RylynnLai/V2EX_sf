//
//  RLNodeBubbles.swift
//  V2EX
//
//  Created by LLZ on 16/5/9.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit
import Alamofire

class RLNodeBubbles: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view.
    }

    private func loadData()  {
//        RLNetWorkManager.defaultNetWorkManager.requestWithPath("/api/nodes/all.json", success: {[weak self] (response) in
//            let allNodes = RLNode.mj_objectArrayWithKeyValuesArray(response)
//            let nodeModels:NSMutableSet = NSMutableSet.init(array: allNodes as [AnyObject])
//            for node in nodeModels{
//                if Int((node as! Node).topics!)! < 100 {//话题数目少于100条的不显示
//                    nodeModels.removeObject(node)
//                }
//            }
//            if let strongSelf = self {
//                strongSelf.bubblesView.nodeModels = nodeModels
//            }
//            }, failure:{})
        
        
        
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


}
