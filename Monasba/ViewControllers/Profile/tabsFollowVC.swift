//
//  sdd.swift
//  Monasba
//
//  Created by iOSayed on 15/06/2023.
//


import UIKit
import Alamofire

class tabsFollowVC: UIViewController {
    
    @IBOutlet weak var pages: UIView!
    var tabs = [tab]()
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    var cids = ["followings","followers"]
  
    override func viewDidLoad() {
        super.viewDidLoad()
        initTabs()
    }
    
    
    func initTabs(){
        tabs.append(tab(i: "Followings".localize))
        tabs.append(tab(i: "Followers".localize))
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        let frame =  CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height )
        options = ViewPagerOptions(viewPagerWithFrame: frame)
        options.tabType = ViewPagerTabType.basic
        //options.tabViewImageSize = CGSize(width: 20, height: 20)
        options.tabViewTextFont = UIFont(name: "Tajawal-Bold", size: 15)!
        options.tabViewPaddingLeft = 10
        options.tabViewPaddingRight = 10
        
        
//         options.tabViewTextDefaultColor = UIColor(hexString: "#9AA6AE")
//        options.tabViewTextHighlightColor = UIColor(hexString: "#0EBFB1")
        options.tabViewTextDefaultColor = UIColor(hexString: "#9AA6AE")
        options.tabViewTextHighlightColor = UIColor(hexString: "#0EBFB1")
        options.viewPagerTransitionStyle = .scroll
        options.isTabHighlightAvailable = true
        options.tabViewBackgroundDefaultColor = UIColor.white
        options.tabViewBackgroundHighlightColor = UIColor.white
        
        options.isTabIndicatorAvailable = true
        options.tabIndicatorViewBackgroundColor = UIColor(hexString: "#0EBFB1")
        options.tabIndicatorViewHeight = 3.5
        
        options.fitAllTabsInView = true
        options.textCorner = 0
        options.tabViewHeight = 50
        
        viewPager = ViewPagerController()
        viewPager.options = options
        viewPager.dataSource = self
        viewPager.delegate = self
        options.viewPagerFrame = self.view.bounds
        
        self.addChild(viewPager)
        pages.addSubview(viewPager.view)
        viewPager.didMove(toParent: self)
    }
    
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismissDetail()
    }
    
    
}

extension tabsFollowVC: ViewPagerControllerDataSource {
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position:Int) -> UIViewController {
//        order.which_follow = cids[position]
        return getViewController("followersVC",PROFILE_STORYBOARD)
    }
    
    func tabsForPages() -> [tab] {
        return tabs
    }
    
    func startViewPagerAtIndex() -> Int {
        return 0
    }
}

extension tabsFollowVC: ViewPagerControllerDelegate {
    
    func willMoveToControllerAtIndex(index:Int) {
        print("index=\(index)")
        Constants.followIndex = index
    }
    
    func didMoveToControllerAtIndex(index: Int) {
        print("Moved to page \(index)")
    }
}
