//
//  ss.swift
//  Monasba
//
//  Created by iOSayed on 15/06/2023.
//
import UIKit
import Alamofire

class followersVC: UIViewController {
    var data = [FollowersSuccessData]()
    var url = URL(string: "")
    var otherUserId = 0
    @IBOutlet weak var lst: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lst.backgroundColor = UIColor.clear.withAlphaComponent(0)
        lst.register(UINib(nibName: "FollowTVCell", bundle: nil), forCellReuseIdentifier: "FollowTVCell")
        delay(0.5) {
            self.get()
        }
        
    }
    
    func clear_all(){
        data.removeAll()
        lst.reloadData()
    }
    
    
    func get(){
        clear_all()
//        let params : [String: Any]  = ["method":order.which_follow,"uid":user.id,"other_id":user.other_id]
        let params : [String: Any]  = ["user_id":Constants.followOtherUserId]
            print(params)
        if Constants.followIndex == 0 {
            url = URL(string: Constants.DOMAIN + "following")
            AF.request(url!, method: .post, parameters: params)
                .responseDecodable(of: FollowingsSuccessModel.self) { e in
                    print(e)
                    switch e.result {
                    case let .success(data):
                        if let data = data.data?.data {
                            self.data.append(contentsOf: data)
                        }
                        
                        DispatchQueue.main.async {
                            self.lst.reloadData()
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
        }else{
            Constants.followIndex = 0
            url = URL(string: Constants.DOMAIN + "followers")
            AF.request(url!, method: .post, parameters: params)
                .responseDecodable(of: FollowersSuccessModel.self) { e in
                    print(e)
                    switch e.result {
                    case let .success(data):
                        if let data = data.data {
                            self.data.append(contentsOf: data)
                        }
                        
                        DispatchQueue.main.async {
                            self.lst.reloadData()
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
        }
    }
    
    
  
}

extension followersVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inx = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTVCell", for: indexPath) as! FollowTVCell
            cell.configureFollow(data: data[inx])
            cell.btn_follow.tag = inx
            cell.btn_follow.addTarget(self, action: #selector(go_follow), for: .touchUpInside)
        return cell
    }

   @objc func go_follow(_ sender:UIButton){
       if Constants.followIndex == 0  {
           //following
             otherUserId = data[sender.tag].toID ?? 0
       }else{
           //followers
             otherUserId = data[sender.tag].userID ?? 0
       }
//       guard  let otherUserId = data[sender.tag].userID,let url = URL(string: Constants.DOMAIN+"make_follow") else {return}
       guard let url = URL(string: Constants.DOMAIN+"make_follow") else {return}
       print(otherUserId)
       let params : [String: Any]  = ["to_id":otherUserId]
       print(params)
       AF.request(url, method: .post, parameters: params,headers: Constants.headerProd).responseDecodable(of:SuccessModel.self){res in
           switch res.result {
           case .success(let data):
               if let message = data.message {
                   if message.contains("Added Successfully".localize){
                       StaticFunctions.createSuccessAlert(msg: message)
                       self.get()
                   }
               }
           case .failure(let error):
               StaticFunctions.createErrorAlert(msg: "Error Data Type")
               print(error)
           }
       }
   }
   
    
   func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
       return CGSize(width: lst.frame.width - 20, height: 80)
   }
   
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       let inx = indexPath.row
       guard let id = data[inx].toID else {return}
//        user.other_id = "\(id)"
//        goNav("otherProfilev","Profile")
   }
}
