//
//  ViewController.swift
//  YLPTagsView
//
//  Created by shangchao on 2018/2/13.
//  Copyright © 2018年 shangchao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let tagsView = TagsView(frame: CGRect(x: 20, y: 84, width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 84 - 69))
    var titleArray: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select State"
        view.addSubview(tagsView)
        tagsView.tagTitles = titleArray
        tagsView.stateChanged = { isSelecting in
            print(isSelecting)
            if isSelecting {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(self.add))
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(self.edit))
            }
            self.title = !isSelecting ? "Edit State" : "Select State"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(add))
        
    }
    
    @objc func add(){
        let string = RandomString.sharedInstance.getRandomString()
        print(string)
        
        tagsView.addTag(title: string)
    }
    
    @objc func edit(){
        tagsView.isSelectState = true
    }
    
}


/// 随机字符串生成
class RandomString {
    let characters = "abcdefghij安安；两年前热过去の🆚吗八宝饭那，bna.b,klmnopqrst1234567890uvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    /**
     生成随机字符串,
     
     - parameter length: 生成的字符串的长度
     
     - returns: 随机生成的字符串
     */
    func getRandomStringOfLength(length: Int) -> String {
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            
            for c in characters {
                if characters.index(of: c)?.encodedOffset == index {
                    ranStr += String(c)
                }
                
            }
        }
        return ranStr
        
    }
    
    func getRandomString() -> String{
        return getRandomStringOfLength(length: Int(3 + arc4random_uniform(5)))
    }
    
    
    private init() {
        
    }
    static let sharedInstance = RandomString()
}

