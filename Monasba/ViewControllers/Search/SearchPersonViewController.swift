//
//  SearchPersonViewController.swift
//  Monasba
//
//  Created by Amal Elgalant on 23/05/2023.
//

import UIKit

class SearchPersonViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var users = [User]()
    var page = 1
    var isTheLast = false
    var searchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
//        getData()
        // Do any additional setup after loading the view.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SearchPersonViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FollowerTableViewCell
        cell.setData(user: users[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: PROFILE_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: OTHER_USER_PROFILE_VCID) as! OtherUserProfileVC
        vc.navigationController?.navigationBar.isHidden = true
        vc.OtherUserId = users[indexPath.row].id ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (users.count-1) && !isTheLast{
            page+=1
            getData()

        }
    }
    

}

extension SearchPersonViewController{
    func getData(){
        SearchController.shared.searchPerson(completion: {
            users, check, msg in
            if check == 0{
                if self.page == 1 {
                    self.users.removeAll()
                    self.users = users
                    
                }else{
                    self.users.append(contentsOf: users)
                }
                if users.isEmpty{
                    self.page = self.page == 1 ? 1 : self.page - 1
                    self.isTheLast = true
                }
                self.tableView.reloadData()
            }else{
                StaticFunctions.createErrorAlert(msg: msg)
                self.page = self.page == 1 ? 1 : self.page - 1
            }
        }, id: AppDelegate.currentUser.id ?? 0, searchText: searchText, page: self.page)
    }
}
extension SearchPersonViewController: ContentDelegate{
    func updateContent(searchText: String) {
        self.searchText = searchText
        getData()
    }
    
    
}
