//
//  TabScrollView.swift
//  ScrollTab
//
//  Created by 柯柯哥 on 2023/12/18.
//

import UIKit

protocol TabScrollViewDelegate : NSObjectProtocol {
    func didSelectOneTab(tabTitle:String,tabIndex:Int)
}
class TabScrollView: UIView {
/** 当前选中的Tab */
    var selectTab : String = ""
    /** 未选中状态下的标题颜色 */
    var normalTitleColor : UIColor = .white
    /** 选中状态下的标题颜色 */
    var selectedTitleColor : UIColor = .white
    /** 未选中状态下的标题字号 */
    var normalTitleFontSize : CGFloat   = 13.0
    /** 选中状态下的标题字号 */
    var selectedTitleFontSize : CGFloat = 18.0
    /** 每个item之间的间距  */
    var itemSpacing :CGFloat = 16.0
    /** 选中Tab时候是否添加一个指示条 */
    var isShowBottomIndicatorLine : Bool = true
    /** 选中Tab时候添加指示条的颜色 */
    var indicatorLineColor : UIColor = .white
    /** 选中Tab时候添加指示条宽度，最多跟标题齐宽 */
    var indicatorWidth : CGFloat = 16.0
    /** 选中Tab时候添加指示条高度 */
    var indicatorHeight : CGFloat = 2.0
    /** 用户点击回传信息 */
    weak var delegate:TabScrollViewDelegate?
    var tabTitles : [String]?{
        didSet{
            guard let tabTitles = tabTitles else {return}
            addTabItems(titleArray: tabTitles)
        }
    }
    private lazy var menuScrollView : UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.showsHorizontalScrollIndicator = false;
        
        scrollView.alwaysBounceHorizontal = true;
       return scrollView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addChildViews()
    }
    //MARK: - 添加子视图
    private func addChildViews(){
        addSubview(menuScrollView)
        menuScrollView.frame = bounds
    }
    private func addTabItems(titleArray:[String]){
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = itemSpacing
        menuScrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(equalToConstant: menuScrollView.frame.height).isActive = true
        stackView.leftAnchor.constraint(equalTo: menuScrollView.leftAnchor).isActive = true
        
        for (index,menuItem) in titleArray.enumerated() {
            let itemStackView = UIStackView()
            itemStackView.axis = .vertical;
            itemStackView.alignment = .center;
            itemStackView.distribution = .equalSpacing;
            itemStackView.spacing = 2.0;
            itemStackView.tag = index + 100;
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(clickToSelectOneModule(tapGesture:)))
            itemStackView.addGestureRecognizer(tapGesture);
            stackView.addArrangedSubview(itemStackView);
            
            let menuBtn = UIButton();
            menuBtn.setTitle(menuItem, for: .normal);
            if(menuItem == selectTab)
            {
                menuBtn.titleLabel?.font = .boldSystemFont(ofSize: selectedTitleFontSize);
                menuBtn.setTitleColor(normalTitleColor, for: .selected);
            }
            else
            {
                menuBtn.titleLabel?.font = .systemFont(ofSize: normalTitleFontSize);
                menuBtn.contentEdgeInsets = UIEdgeInsets(top: (frame.size.height - normalTitleFontSize) / 2.0, left: 0, bottom: (frame.size.height - normalTitleFontSize) / 2.0, right: 0);
                menuBtn.setTitleColor(normalTitleColor, for: .normal);
            }
            
            
            menuBtn.setContentHuggingPriority(UILayoutPriority(98), for: .horizontal);
            itemStackView.addArrangedSubview(menuBtn);
            menuBtn.isUserInteractionEnabled = false;
            //            看是否选中
            if(menuItem == selectTab)
            {
                if(isShowBottomIndicatorLine)
                {
                    let lineView = UIView();
                    lineView.backgroundColor = indicatorLineColor;
                    itemStackView.addArrangedSubview(lineView);
                    lineView.translatesAutoresizingMaskIntoConstraints = false;
                    
                    lineView.widthAnchor.constraint(equalToConstant: indicatorWidth).isActive = true;
                    lineView.heightAnchor.constraint(equalToConstant: indicatorHeight).isActive = true;
                    lineView.setContentHuggingPriority(UILayoutPriority(99), for: .horizontal);
                    lineView.centerXAnchor.constraint(equalTo: itemStackView.centerXAnchor).isActive = true;
                }
                
            }
        }
        stackView.layoutIfNeeded();
        menuScrollView.contentSize = CGSize(width: stackView.frame.width, height: menuScrollView.frame.height);
    }
    //MARK: 选中某个模块
    @objc private func clickToSelectOneModule(tapGesture:UITapGestureRecognizer)
    {
        guard let gestureView = tapGesture.view,let activeModules = tabTitles else{ return}
        let moduleIndex = gestureView.tag - 100;
        let activeModule = activeModules[moduleIndex];
        selectTab = activeModule;
        var scrollVisibleIndex = 0;
        var needScroll = true;
        //
        if let previousView = gestureView.superview?.viewWithTag(moduleIndex - 1 + 100)
        {
            if let nextView = gestureView.superview?.viewWithTag(moduleIndex + 1 + 100)
            {
                //如果当前点击的模块前后模块都完整展示，那么就不需要做偏移
                if(previousView.frame.origin.x >= menuScrollView.contentOffset.x && (menuScrollView.contentOffset.x >= (nextView.frame.origin.x - (menuScrollView.frame.width - nextView.frame.width))))
                {
                    needScroll = false;
                }
                else
                {
                    if(gestureView.frame.origin.x >= menuScrollView.contentOffset.x + menuScrollView.frame.width * 0.5)
                    {
                        scrollVisibleIndex = nextView.tag;
                    }
                    else
                    {
                        scrollVisibleIndex = previousView.tag;
                    }
                }
            }
            else
            {
                //点击最后一个
                scrollVisibleIndex = gestureView.tag;
            }
        }
        else
        {
            //那就是点的第一个
            scrollVisibleIndex = gestureView.tag;
        }
        
        while menuScrollView.subviews.count > 0 {
            menuScrollView.subviews.last?.removeFromSuperview();
        }
        addTabItems(titleArray: activeModules);
        if let boxStackView = menuScrollView.subviews.last,let visibleItem = boxStackView.viewWithTag(scrollVisibleIndex),needScroll
        {
            menuScrollView.scrollRectToVisible(visibleItem.frame, animated: true);
        }
        print("选中模块=\(activeModule)");
        delegate?.didSelectOneTab(tabTitle: activeModule, tabIndex: moduleIndex);
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
