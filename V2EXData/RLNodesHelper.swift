//
//  RLNodesHelper.swift
//  V2EX
//
//  Created by LLZ on 16/5/13.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
import Alamofire

class RLNodesHelper: NSObject {
    static let shareNodesHelper = RLNodesHelper()//单例
    private override init() {}//防止外部用init（）或者（）来初始化这个单例
    
    func nodeWithNodeID(ID:NSNumber, completion:(node:Node?) -> Void) {
        let path = "/api/nodes/show.json?id=\(ID)"
        
        Alamofire.request(.GET, mainURLStr + path).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error 获取话题失败: \(response.result.error)")
                completion(node: .None)
                return
            }
            if let responseJSON = response.result.value as? [AnyObject]{
                let node = Node.createNode(fromKeyValues: responseJSON.first!)
                completion(node: node)
            }
        }
    }
    
    func nodesWithCompletion(completion:(nodes:[Node]?) -> Void) {
        Alamofire.request(.GET, mainURLStr + "/api/nodes/all.json").responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error 获取所有节点数据失败: \(response.result.error)")
                return
            }
            if let responseJSON = response.result.value as? [NSDictionary] {
                let nodes =  Node.createNodesArray(fromKeyValuesArray: responseJSON)
                completion(nodes: nodes)
            }
        }
    }
    
}