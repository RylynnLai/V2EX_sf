//
//  RLNodeTopicCell.swift
//  V2EX
//
//  Created by LLZ on 16/5/12.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

class RLNodeTopicCell: UITableViewCell {

    var topicModel:Topic? {
        didSet{
            titleLable.text = topicModel?.title
            //以下两项没数据就空白
            contentLable.text = topicModel?.content
            //-------------------------------------------------
            let iconURL = NSURL.init(string: "http:\(topicModel!.member!.avatar_normal ?? "")")
            authorBtn.sd_setBackgroundImageWithURL(iconURL, forState: .Normal, placeholderImage: UIImage.init(named: "blank"))
            replieNumLable.text = topicModel?.replies?.stringValue
        }
    }
    
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var contentLable: UILabel!
    @IBOutlet weak var authorBtn: UIButton!
    @IBOutlet weak var replieNumLable: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        authorBtn.layer.cornerRadius = authorBtn.bounds.size.height * 0.5
        authorBtn.layer.masksToBounds = true
        replieNumLable.layer.cornerRadius = replieNumLable.bounds.size.height * 0.5
        replieNumLable.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
