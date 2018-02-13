//
//  TagsView.swift
//  DateNote
//
//  Created by shangchao on 2018/2/8.
//  Copyright © 2018年 杨立鹏. All rights reserved.
//

import UIKit

class TagsView: UIView {
    typealias StateChanged = (_ isSelectState : Bool) -> ()
    
    
    private let scrollView = UIScrollView()
    private var isRefreshAll = true // 是否刷新全部
    private var isMoving = false // 是否正在拖拽标签
    var stateChanged: StateChanged? // 状态改变的回调
    var isSelectState = true { // 选择状态（true） 还是 编辑状态(false)
        willSet{
            selectingStateChange(isSelectState: newValue)
            
        }
    }
    private var touchButtonFrame: CGRect = .zero
    var tagTitles:[String] = [] {
        didSet{
            if isRefreshAll {
                reload()
            }
        }
    }
    // 标签按钮数组
    private var buttons:[UIButton] = []
    // 标签位置数组
    private var tagFrames:[CGRect] = []
    
    // 标签的margin
    var marginH: CGFloat = 20
    var marginV: CGFloat = 10
    
    // 标签的padding
    var paddingH: CGFloat = 10
    var paddingV: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(scrollView)
        
        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: frame.size.width, height: 500)
        
        reload()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 加载tagsView
    func reload() {
        
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        
        tagFrames = []
        buttons = []
        
        var rowIndex = 0
        
        var x: CGFloat = marginH * 0.5
        var y: CGFloat = marginV
        
        var maxY: CGFloat = 0
        for title in tagTitles {
            
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            let attribute = [NSAttributedStringKey.font: button.titleLabel!.font!]
            let size = title.size(withAttributes: attribute)
            scrollView.addSubview(button)
            button.backgroundColor = .gray
            
            let buttonW = size.width + paddingH
            let buttonH = size.height + paddingV
            
            button.frame = CGRect(x: x, y: y, width: buttonW, height: buttonH)
            button.backgroundColor = #colorLiteral(red: 0.1607843137, green: 0.5019607843, blue: 0.7254901961, alpha: 1)
            button.layer.cornerRadius = 3.0
            let newMaxX = x + size.width + paddingH
            
            rowIndex += 1
            if newMaxX > frame.size.width - marginH * 0.5 {
                
                rowIndex = 0
                x = marginH * 0.5
                y += size.height + paddingV + marginV
                button.frame = CGRect(x: x, y: y, width: buttonW, height: buttonH)
                x += buttonW + marginH
                
            } else {
                x = newMaxX + marginH
            }
            tagFrames.append(button.frame)
            maxY = y + size.height + paddingV + marginV
            
            button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
            
            let panGest = UIPanGestureRecognizer(target: self, action: #selector(move(At:)))
            button.addGestureRecognizer(panGest)
            let longGest = UILongPressGestureRecognizer(target: self, action: #selector(enterEidtState))
            button.addGestureRecognizer(longGest)
            buttons.append(button)
        }
        scrollView.contentSize.height = maxY
        if maxY > frame.size.height {
            scrollView.setContentOffset(CGPoint(x: 0, y: maxY - frame.size.height), animated: true)
        }
        
    }
    
    @objc func enterEidtState( gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            isSelectState = !isSelectState
        }
    }
    
    /// 拖动tag标签
    ///
    /// - Parameter gesture: 拖动手势
    @objc
    func move(At gesture: UIPanGestureRecognizer) {
        
        if !isSelectState {
            let panButton = gesture.view as! UIButton
            
            if isMoving {
                
                let noGesture = gesture.state == .ended || gesture.state == .cancelled
                
                if noGesture {
                    panButton.frame = touchButtonFrame
                    isMoving = false
                    
                } else {
                    let point = gesture.translation(in: scrollView)
                    let offsetLoc = gesture.location(in: gesture.view)
                    gesture.view?.center = CGPoint(x: (gesture.view?.center.x)! + point.x + offsetLoc.x - (gesture.view?.frame.size.width)! * 0.5, y: (gesture.view?.center.y)! + point.y + offsetLoc.y - (gesture.view?.frame.size.height)! * 0.5)
                    
                    gesture.setTranslation(.zero, in: scrollView)
                    
                    gesture.view?.superview?.bringSubview(toFront: gesture.view!)
                    
                    var targetButton: UIButton = UIButton()
                    for button in buttons {
                        let buttonMinX = button.frame.origin.x - marginH * 0.5
                        let buttonMinY = button.frame.origin.y - marginV * 0.5
                        let buttonMaxX = button.frame.origin.x + button.frame.size.width + marginH * 0.5
                        let buttonMaxY = button.frame.origin.y + button.frame.size.height + marginV * 0.5
                        if ((panButton.center.x > buttonMinX) && (panButton.center.x < buttonMaxX) && (panButton.center.y > buttonMinY) && (panButton.center.y < buttonMaxY) && panButton != button) {
                            
                            print(button.currentTitle!)
                            targetButton = button
                            
                            
                            let touchIndex = tagTitles.index(of: panButton.currentTitle!)!
                            isRefreshAll = false
                            
                            let insertIndex = buttons.index(of: targetButton)!
                            
                            reload(at: panButton, touchIndex: touchIndex, to: insertIndex)
                            isRefreshAll = true
                        }
                    }
                }
            } else {
                touchButtonFrame = panButton.frame
                isMoving = true
            }
        }
        
    }
    
    
    /// 添加标签
    ///
    /// - Parameter title: 新标签的文字
    func addTag( title: String ){
        isRefreshAll = false
        
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        let attribute = [NSAttributedStringKey.font: button.titleLabel!.font!]
        let size = title.size(withAttributes: attribute)
        scrollView.addSubview(button)
        button.layer.cornerRadius = 3.0
        button.backgroundColor = .gray
        
        if tagTitles.isEmpty {
            tagTitles = [title]
            
            
            
            buttons = [button]
            tagFrames = [CGRect(x: marginH * 0.5, y: marginV, width: size.width + paddingH, height: size.height + paddingV)]
            button.frame = tagFrames.first!
            
        } else {
            tagTitles.append(title)
           
            var x: CGFloat = (tagFrames.last?.maxX)! + marginH
            var y: CGFloat = (tagFrames.last?.minY)!
            
            var maxY: CGFloat = y
            
            let buttonW = size.width + paddingH
            let buttonH = size.height + paddingV
            
            button.frame = CGRect(x: x, y: y, width: buttonW, height: buttonH)
            
            let newMaxX = x + size.width + paddingH
            
            if newMaxX > frame.size.width - marginH * 0.5 {
                
                x = marginH * 0.5
                y += size.height + paddingV + marginV
                button.frame = CGRect(x: x, y: y, width: buttonW, height: buttonH)
                x += buttonW + marginH
                
            } else {
                x = newMaxX + marginH
            }
            tagFrames.append(button.frame)
            maxY = y + size.height + paddingV + marginV
            
            button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
            
            let panGest = UIPanGestureRecognizer(target: self, action: #selector(move(At:)))
            button.addGestureRecognizer(panGest)
            let longGest = UILongPressGestureRecognizer(target: self, action: #selector(enterEidtState))
            button.addGestureRecognizer(longGest)
            buttons.append(button)
            
            scrollView.contentSize.height = maxY
            if maxY > frame.size.height {
                scrollView.setContentOffset(CGPoint(x: 0, y: maxY - frame.size.height), animated: true)
            }
        }
        isRefreshAll = true
    }
    
    
    /// 移动
    ///
    /// - Parameter index: 索引
    func reload(at touchButton:UIButton, touchIndex: Int, to insertIndex: Int) {
        
        tagTitles.remove(at: touchIndex)
        let tagFrame = tagFrames.remove(at: touchIndex)
        let button = buttons.remove(at: touchIndex)
        tagTitles.insert(touchButton.currentTitle!, at: insertIndex)
        tagFrames.insert(tagFrame, at: insertIndex)
        buttons.insert(button, at: insertIndex)
        
        let index = touchIndex > insertIndex ? insertIndex : touchIndex
        
        let changeFrames = tagFrames[index...]
        print(changeFrames.count)
        
        var x: CGFloat = marginH * 0.5
        var y: CGFloat = marginV
        
        if index != 0 {
            x = (tagFrames[index - 1].origin.x) + marginH + (tagFrames[index - 1].size.width)
            y = (tagFrames[index - 1].origin.y)
        }
        
        var maxY: CGFloat = 0
        var viewIndex = 0
        
        for tagFrame in changeFrames {
            
            
            var origin: CGPoint = .zero
            
            origin = CGPoint(x: x, y: y)
            
            let newMaxX = x + tagFrame.size.width
            
            if newMaxX > self.frame.size.width - marginH * 0.5 {
                
                x = marginH * 0.5
                y += tagFrame.size.height + marginV
                origin = CGPoint(x: x, y: y)
                x += tagFrame.size.width + marginH
                
            } else {
                x = newMaxX + marginH
            }
            
            maxY = y + tagFrame.size.height + marginV
            
            tagFrames[index + viewIndex].origin = origin
            
            viewIndex += 1
            
            
        }
        
        
        scrollView.contentSize.height = maxY
        
        UIView.animate(withDuration: 0.5) {
            for button in self.buttons {
                
                let newFrame = self.tagFrames[self.buttons.index(of: button)!]
                if button != touchButton {
                    button.frame.origin = newFrame.origin
                    
                } else {
                    
                    self.touchButtonFrame = newFrame
                }
            }
        }
    }
    

    func delete(At index: Int) {
       
        
        let removeButton = buttons.remove(at: index)
        removeButton.removeFromSuperview()
        tagFrames.remove(at: index)
        tagTitles.remove(at: index)
        
        
        var x: CGFloat = marginH * 0.5
        var y: CGFloat = marginV
        
        if index != 0 {
            x = removeButton.frame.origin.x
            y = removeButton.frame.origin.y
        }
        
        var maxY: CGFloat = y
        var viewIndex = 0
        let changeFrame = tagFrames[index...]
        for newframe in changeFrame {
            var origin = CGPoint(x: x, y: y)
            let newMaxX = x + newframe.size.width
            
            if newMaxX > self.frame.size.width - marginH * 0.5 {
                
                x = marginH * 0.5
                y += newframe.size.height + marginV
                origin = CGPoint(x: x, y: y)
                x += newframe.width + marginH
                
            } else {
                x = newMaxX + marginH
            }
            tagFrames[index + viewIndex].origin = origin
            maxY = y + newframe.size.height + marginV
            
            viewIndex += 1
        }
        scrollView.contentSize.height = maxY
        
        UIView.animate(withDuration: 0.5) {
            for button in self.buttons {
                button.frame = self.tagFrames[self.buttons.index(of: button)!]
            }
        }
        
        
    }
    
    @objc
    func buttonClick(sender: UIButton) {
        
        let index = buttons.index(of: sender)
        if isSelectState {
            sender.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        } else {
            
            isRefreshAll = false
            delete(At: index!)
            isRefreshAll = true
        }
    }
    
    //MARK: 回调事件
    func selectingStateChange( isSelectState:Bool) {
        stateChanged?(isSelectState)
    }
}
