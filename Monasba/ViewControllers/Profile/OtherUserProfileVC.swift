//
//  OtherUserProfileVC.swift
//  Monasba
//
//  Created by iOSayed on 01/05/2023.
//

import UIKit
import Alamofire
import MOLH

class OtherUserProfileVC: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var blockAndReportStackView: UIStackView!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var CoverImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userVerifiedImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameUserLabel: UILabel!
    @IBOutlet weak var UserLocationLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var advsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingsCountLabel: UILabel!
    @IBOutlet weak var pages: UIView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    var OtherUserId = 0
    var tabs = [tab]()
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    var cids = ["ads","ratings"]
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        getProfile()
        setupProfileUI()
        initTabs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           navigationController?.navigationBar.isHidden = true
           tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    //MARK: Methods
    
    fileprivate func setupProfileUI(){
        if user.id == OtherUserId {
            blockAndReportStackView.isHidden = true
            followView.isHidden = true
        }else{
            blockAndReportStackView.isHidden = false
            followView.isHidden = false
        }
    }
    
    func initTabs(){
        tabs.append(tab(i: "advertisements".localize))
        tabs.append(tab(i: "Rates".localize))
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        let frame =  CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height )
        options = ViewPagerOptions(viewPagerWithFrame: frame)
        options.tabType = ViewPagerTabType.basic
        //options.tabViewImageSize = CGSize(width: 20, height: 20)
        options.tabViewTextFont = UIFont(name: "Tajawal-Bold", size: 15)!
        options.tabViewPaddingLeft = 10
        options.tabViewPaddingRight = 10
        
        options.tabViewTextDefaultColor = UIColor(hexString: "#9AA6AE")
        options.tabViewTextHighlightColor = UIColor(hexString: "#0EBFB1")
        options.viewPagerTransitionStyle = .scroll
        options.isTabHighlightAvailable = true
        options.tabViewBackgroundDefaultColor = UIColor.white
        options.tabViewBackgroundHighlightColor = UIColor.white
        
        options.isTabIndicatorAvailable = true
        options.tabIndicatorViewBackgroundColor = UIColor(hexString: "#0EBFB1")
        options.tabIndicatorViewHeight = 2.3
        
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
    
    
    

    @IBAction func BackBtnAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareBtnAction(_ sender: UIButton) {
        shareContent(text: "share Profile of ")
    }
    
    @IBAction func reportAboutUserBtnAction(_ sender: UIButton) {
        
    }
    
    @IBAction func blockUserBtnAction(_ sender: UIButton) {
        
    }
    
    @IBAction func followBtnAction(_ sender: UIButton) {

     guard let url = URL(string: Constants.DOMAIN+"make_follow") else {return}
     let params : [String: Any]  = ["to_id":OtherUserId]
     print(params)
     AF.request(url, method: .post, parameters: params,headers: Constants.headerProd).responseDecodable(of:SuccessModel.self){res in
//         BG.hide(self)
         print(Constants.headerProd)
         switch res.result {
         case .success(let data):
             if let message = data.message {
                 StaticFunctions.createSuccessAlert(msg: message)
                 self.getProfile()
             }
         case .failure(let error):
             print(error)
         }
     }
    }
    
    @IBAction func activeNotificationBtnAction(_ sender: UIButton) {
        let params : [String: Any]  = ["uid":  OtherUserId,
                                       "anther_user_id":AppDelegate.currentUser.id ?? 0]
        guard let url = URL(string: Constants.DOMAIN+"active_fuser_notification") else {return}
        print(params)
        AF.request(url, method: .post, parameters: params)
            .responseDecodable(of:SuccessModel.self){ [weak self ]res in
                guard let self else {return }
                switch res.result {
                   
                case .success(let data):
                    if let message = data.message {
                        DispatchQueue.global().async {
                            self.getProfile()
                        }
                        StaticFunctions.createSuccessAlert(msg: message)
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
    @IBAction func advsBtnAction(_ sender: UIButton) {
//        if let vc = UIStoryboard(name: MENU_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: MYADS_VCID) as? MyAdsVC {
//            vc.modalPresentationStyle = .fullScreen
//            vc.userId = OtherUserId
//            presentDetail(vc)
//        }
    }
    
    @IBAction func FollowersBtnAction(_ sender: UIButton) {
        let vc = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "tabFollowVC") as! tabsFollowVC
        Constants.followIndex = 1
        Constants.followOtherUserId = OtherUserId
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func followingsBtnAction(_ sender: UIButton) {
        let vc = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: "tabFollowVC") as! tabsFollowVC
        Constants.followIndex = 0
        Constants.followOtherUserId = OtherUserId
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func chatBtnAction(_ sender: UIButton) {
        
        
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        Constants.userOtherId = "\(OtherUserId)"
        vc.modalPresentationStyle = .fullScreen
        
        createRoom("\(OtherUserId)"){[weak self] success in
            guard let self = self else {return}
            if success {
//                self.present(vc, animated: true)
                vc.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                StaticFunctions.createErrorAlert(msg: "Can't Create Room".localize)
            }
            
        }
    }
    
    
}
extension OtherUserProfileVC {
    private func getProfile(){
        ProfileController.shared.getOtherProfile(completion: {[weak self] userProfile, msg in
            guard let self = self else {return}
            if let userProfile = userProfile {
                print("======= profile Data ======== ")
                print(userProfile)
                self.bindProfileData(from: userProfile)
               // self.getProductsByUser()
            }
        }, userId: OtherUserId)
    }
    
    private func bindProfileData(from profileModel:User){
        if let cover =  profileModel.cover {
            if cover.contains(".png") || cover.contains(".jpg"){
                CoverImageView.setImageWithLoading(url:profileModel.cover ?? "" )
            }
        }
        if let userPic =  profileModel.pic {
            if userPic.contains(".png") || userPic.contains(".jpg"){
                userImageView.setImageWithLoading(url:profileModel.pic ?? "" )
            }
        }
        
        fullNameUserLabel.text = "\(profileModel.name ?? "") \(profileModel.lastName ?? "")"
        if profileModel.verified != 0 {
            userVerifiedImageView.isHidden = false
        }else{
            userVerifiedImageView.isHidden = true
        }
        
        advsCountLabel.text = "\(profileModel.numberOfProds ?? 0)"
        followersCountLabel.text = "\(profileModel.followers ?? 0)"
        followingsCountLabel.text = "\(profileModel.following ?? 0)"
        userNameLabel.text = profileModel.username
        userBioLabel.text = profileModel.bio
        if MOLHLanguage.currentAppleLanguage() == "en" {
            UserLocationLabel.text = "\(profileModel.countriesNameEn ?? "") - \(profileModel.citiesNameEn ?? "")"
        }else {
            UserLocationLabel.text = "\(profileModel.countriesNameAr ?? "") - \(profileModel.citiesNameAr ?? "")"
        }
        
        if profileModel.activeNotification == 1 {
            StaticFunctions.setImageFromAssets(notificationImageView, "bell_fill")
                
            }else{
                StaticFunctions.setImageFromAssets(notificationImageView, "bell_main")
            }
        
        if profileModel.isFollow == 1 {
            self.followButton.setTitle("unfollow".localize, for: .normal)
        }else{
            self.followButton.setTitle("follow".localize, for: .normal)
        }
        
        if AppDelegate.currentUser.id == OtherUserId {
//            self.enable([self.btn_follow,self.btn_not], enabled: false)
//            self.setTxtColor(self.btn_follow,"#000000")
//            self.contactv.constant = 0
            self.chatButton.isHidden = true
            self.followView.isHidden = true
            self.blockAndReportStackView.isHidden = true
        }
        
    }
    
    
    func createRoom(_ recieverId:String, completion:@escaping (Bool)->()){
        let params : [String: Any]  = ["rid":recieverId]
        print(params , "Headers  \(Constants.headerProd)" )
        guard let url = URL(string: Constants.DOMAIN+"create_room")else{return}
        AF.request(url, method: .post, parameters: params, headers: Constants.headerProd).responseDecodable(of:RoomSuccessModel.self) { res in
            print(res)
            switch res.result {
                
            case .success(let data):
                if let receiverId = data.data?.id {
                   
                    print(data)
                    receiver.room_id = "\(receiverId)"
                    print(receiver.room_id)
                    completion(true)
                    
                }
            case .failure(let error):
                print(error)
                completion(false)
            }
        }
        
    }
}

extension OtherUserProfileVC: ViewPagerControllerDataSource {
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position:Int) -> UIViewController {
        if position == 1{
            return getViewController("profileRatesVC",PROFILE_STORYBOARD)
        }else{
            return getViewController("OtherUserProductVC",PROFILE_STORYBOARD)
        }
    }
    
    func tabsForPages() -> [tab] {
        return tabs
    }
    
    func startViewPagerAtIndex() -> Int {
        return 0
    }
}
extension OtherUserProfileVC: ViewPagerControllerDelegate {
    
    func willMoveToControllerAtIndex(index:Int) {
        print("index=\(index)")
    }
    
    func didMoveToControllerAtIndex(index: Int) {
        if index == 1 {
            chatButton.setTitle("إضافة تقييم", for: .normal)
        }else{
            chatButton.setTitle("محادثة", for: .normal)
        }
    }
}
