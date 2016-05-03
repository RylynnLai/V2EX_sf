//
//  RLTopicContent.swift
//  V2EX
//
//  Created by LLZ on 16/4/29.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

class RLTopicContent: UIViewController {
    @IBOutlet weak var loadingAIV: UIActivityIndicatorView!
    @IBOutlet weak var authorLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var createdTimeLable: UILabel!
    @IBOutlet weak var authorBtn: UIButton!
    @IBOutlet weak var replieNumLable: UILabel!
    @IBOutlet weak var contentWbV: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
