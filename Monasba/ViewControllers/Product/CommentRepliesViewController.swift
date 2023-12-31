//
//  CommentRepliesViewController.swift
//  Monasba
//
//  Created by Amal Elgalant on 25/05/2023.
//

import UIKit

class CommentRepliesViewController: UIViewController {
   
   
    //comments
    @IBOutlet weak var lst: UITableView!
    var data = CommentsReplayObject()
    
    @IBOutlet weak var countOfCommentsLabel: UILabel!
    //data
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_comment: UILabel!
    @IBOutlet weak var img_user: UIImageView!
    
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        lst.rowHeight = UITableView.automaticDimension
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateData(_:)), name: NSNotification.Name(rawValue: "updateData"), object: nil)
        
//        countOfCommentsLabel.text = "مشاهدة التعليقات (\(replaiesCount))"
        // Do any additional setup after loading the view.
    }
  
    @objc func updateData(_ notification: NSNotification) {
        getData()
        
    }
    
    @IBAction func addReplyAction(_ sender: Any) {
        let vc = UIStoryboard(name: PRODUCT_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: REPLY_VCID) as! ReplyViewController
        vc.id = self.data.comment?.id ?? 0
        self.present(vc, animated: false, completion: nil)
        
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
extension CommentRepliesViewController{
func getData(){
        ProductController.shared.getCommentsReply(completion: {
            commentReply, check, msg in
            if check == 0{

                self.data = commentReply
                self.setData()

                self.lst.reloadData()
            }else{
                self.data = commentReply
                self.lst.reloadData()
                StaticFunctions.createErrorAlert(msg: msg)
                
            }
            
            
        }, id: data.comment?.id ?? 0)
    }
   func setData(){
        self.img_user.setImageWithLoading(url: data.comment?.commentUserPic ?? "users/1675802939.png")
        self.lbl_name.text = data.comment?.commentUserName
//        self.lbl_date.text = data.comment?.createdAt?.formattedDateSince
        self.lbl_comment.text = data.comment?.comment
       self.lbl_comment.sizeToFit()
       countOfCommentsLabel.text = "show comments".localize + " (\(data.countReplies ?? 0))"

    }
}
extension CommentRepliesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.replies?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CommentReplyTableViewCell
        cell.setData(reply: data.replies?[indexPath.row] ?? Reply())
        
        cell.removeBtclosure = {
            self.deleteReply(id: self.data.replies?[indexPath.row].id ?? 0)
        }
        
        cell.replyBtclosure = {
            let vc = UIStoryboard(name: PRODUCT_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: REPLY_VCID) as! ReplyViewController
            vc.id = self.data.comment?.id ?? 0
            self.present(vc, animated: false, completion: nil)
            
        }
        cell.flagBtclosure = {
            let vc = UIStoryboard(name: PRODUCT_STORYBOARD, bundle: nil).instantiateViewController(withIdentifier: REPORT_REPLY_VCID) as! ReportReplyViewController
            vc.id = self.data.replies?[indexPath.row].id ?? 0
            self.present(vc, animated: false, completion: nil)
            
        }
        cell.likeBtclosure  = {
            ProductController.shared.likeReply(completion: {
                check, msg in
                if check == 0{
                    
                    
                    
                  var isLike =  self.data.replies?[indexPath.row].isLike == 1 ? 0 : 1
                    
                    self.data.replies?[indexPath.row].isLike = isLike
                    if self.data.replies?[indexPath.row].isLike == 1{
                        self.data.replies?[indexPath.row].likeCount! += 1
                        cell.likeImage.image = UIImage(named: "heartFill")
                    }else{
                        self.data.replies?[indexPath.row].likeCount! += -1
                        cell.likeImage.image = UIImage(named: "heartgrey")
                    }
                    cell.favCountLbl.text = "\(self.data.replies?[indexPath.row].likeCount ?? 0)"

                }else{
                    StaticFunctions.createErrorAlert(msg: msg)

                }
            }, id:  self.data.replies?[indexPath.row].id ?? 0)
        }
        return cell
    }
    
    func deleteReply(id: Int){
        ProductController.shared.deleteReply(completion: {
            check, msg in
            if check == 0{
                self.getData()
            }else{
                StaticFunctions.createErrorAlert(msg: msg)

            }
        }, id:  id)
    }
}
