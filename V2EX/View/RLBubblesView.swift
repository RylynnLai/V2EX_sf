//
//  RLBubblesViewswf.swift
//  V2EX
//
//  Created by ucs on 16/1/14.
//  Copyright © 2016 ucs. All rights reserved.
//

import UIKit
import QuartzCore


class RLBubblesView: UIScrollView, UIScrollViewDelegate {

    // MARk: -setter方法
    var nodeModels:NSSet? {
        didSet{//带属性监视器,表示nodeModels被设置时调用(即使是设置相同的值也会调用)
            let gutter:CGFloat = 20
            let gap:CGFloat = 5
            
            let num = (self.mj_w * 2 - gutter * 2) / (60 + gap)
            let rowNum = nodeModels!.count / Int(num)//这个optional肯定是有值的
            self.contentSize = CGSizeMake(self.mj_w * 2 + (gutter * 2) - gap, CGFloat(rowNum) * (60 + gap) + (gutter * 2))
            self.contentOffset = CGPointMake(self.contentSize.width / 2 - self.mj_w / 2, self.contentSize.height / 2 - self.mj_h / 2)
            
            var xValue = gutter
            var yValue = gutter
            var rowNumber = 1
            
            for nodeModel in nodeModels! {
                let nodeBtn = RLNodeBtn(type:.Custom)
                nodeBtn.frame = CGRectMake(xValue, yValue, 60, 60);
                
                if let nodeM:Node = nodeModel as? Node {//解包
                    nodeBtn.nodeModel = nodeM
                    nodeBtn.setTitle(nodeM.title, forState:UIControlState.Normal)
                }
                
                self.addSubview(nodeBtn)
                nodesBtnArray.addObject(nodeBtn)
                
                nodeBtn.addTarget(self, action: #selector(RLBubblesView.nodeBtnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                xValue += (60 + gap);
                
                if (xValue > (self.contentSize.width - (gutter * 3))) {
                    if (rowNumber % 2 == 1) {
                        xValue = 30 + gutter;
                    }else{
                        xValue = 0 + gutter;
                    }
                    yValue += (60 + gap);
                    rowNumber += 1;
                }
            }
        }
    }
    // MARK: -私有变量
    private var bigSize:CGSize
    private var smallSize:CGSize
    // MARK: -懒加载
    private lazy var nodesBtnArray:NSMutableArray = {[]}()
//    private var nodesBtnArray:[RLNodeBtn]
    private lazy var viewBarrierOuter:UIView = {
        let outerView = UIView.init(frame: CGRectMake(self.mj_w / 8, self.mj_h / 8, self.mj_w * 0.75, self.mj_h * 0.75))
        outerView.backgroundColor = UIColor.redColor()
        outerView.alpha = 0.3
        outerView.hidden = true
        outerView.userInteractionEnabled = false
        self.addSubview(outerView)
        return outerView
    }()
    private lazy var viewBarrierInner:UIView = {
        let innerView = UIView.init(frame: CGRectMake(self.mj_w / 4, self.mj_h / 4, self.mj_w * 0.5, self.mj_h * 0.5))
        innerView.backgroundColor = UIColor.redColor()
        innerView.alpha = 0.3
        innerView.hidden = true
        innerView.userInteractionEnabled = false
        self.addSubview(innerView)
        return innerView
    }()

    
    // 声明一个闭包（空），由外部定义，本类调用
    var nodeBtnAction:(nodeModel:Node) -> Void = {_ in }
    // MARK: -init
    override init(frame: CGRect) {
        bigSize = CGSizeMake(60, 60)
        smallSize = CGSizeMake(30, 30)
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor()
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: -Action
    @objc private func nodeBtnClick(button:RLNodeBtn) {
        if let nodeM = button.nodeModel {
            nodeBtnAction(nodeModel: nodeM)
        }
    }
    
    //MARK: -UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let container = CGRectMake(scrollView.contentOffset.x + (self.viewBarrierOuter.mj_w / 8),
                                   scrollView.contentOffset.y + (self.viewBarrierOuter.mj_h / 8),
                                   self.viewBarrierOuter.mj_w,
                                   self.viewBarrierOuter.mj_h);
        
        let containerTwo = CGRectMake(scrollView.contentOffset.x + (self.viewBarrierInner.mj_w / 2),
                                      scrollView.contentOffset.y + (self.viewBarrierInner.mj_h / 2),
                                      self.viewBarrierInner.mj_w,
                                      self.viewBarrierInner.mj_h);
        
        let fetchQ = dispatch_queue_create("BubbleQueue", nil);
     
        dispatch_async(fetchQ) {
            
            for item in self.nodesBtnArray {
                let nodeBtn:RLNodeBtn = (item as? RLNodeBtn)!
                let thePosition = nodeBtn.frame;

                if CGRectIntersectsRect(containerTwo, thePosition) {
                    if nodeBtn.isZoomAnimating == false {
                        nodeBtn.isZoomAnimating = true
                        dispatch_async(dispatch_get_main_queue()) {
                            UIView.animateWithDuration(0.3, animations: {
                                () -> Void in
                                nodeBtn.transform = CGAffineTransformMakeScale(1.0,1.0)
                                }, completion: {
                                    (finished) -> Void in
                                    nodeBtn.isZoomAnimating = false
                            })
                        }
                    }
                }else if CGRectIntersectsRect(container, thePosition) {
                    if nodeBtn.isZoomAnimating == false {
                        nodeBtn.isZoomAnimating = true;
                        dispatch_async(dispatch_get_main_queue()) {
                            UIView.animateWithDuration(0.3, animations: {
                                () -> Void in
                                nodeBtn.transform = CGAffineTransformMakeScale(0.7,0.7)
                                }, completion: {
                                    (finished) -> Void in
                                    nodeBtn.isZoomAnimating = false
                            })
                        }
                    }
                }else {
                    if nodeBtn.isZoomAnimating == false {
                        nodeBtn.isZoomAnimating = true;
                        dispatch_async(dispatch_get_main_queue()) {
                            UIView.animateWithDuration(0.3, animations: {
                                () -> Void in
                                nodeBtn.transform = CGAffineTransformMakeScale(0.5,0.5)
                                }, completion: {
                                    (finished) -> Void in
                                    nodeBtn.isZoomAnimating = false
                            })
                        }
                    }
                }
            }
        }
    }
}