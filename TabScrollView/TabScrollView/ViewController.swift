//
//  ViewController.swift
//  TabScrollView
//
//  Created by 柯柯哥 on 2023/12/18.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        let tabScrollView = TabScrollView(frame: CGRectMake(16.0, 200.0, UIScreen.main.bounds.width - 32.0, 28.0))
        tabScrollView.backgroundColor = .orange
        view.addSubview(tabScrollView)
        tabScrollView.selectTab = "推荐"
        tabScrollView.tabTitles = ["推荐","辣妹热舞","时政新闻","民生","军事","财经","历史故事","经济胡侃","今日说法"]
        
        print("view.backgroundColor")
    }


}

