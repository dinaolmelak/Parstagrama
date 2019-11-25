//
//  FeedViewController.swift
//  Parstagrama
//
//  Created by Dinaol Melak on 11/18/19.
//  Copyright © 2019 Dinaol Melak. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageInputBarDelegate {
    var refreshControl: UIRefreshControl!
    var posts = [PFObject]()
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add comment here"
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        // Do any additional setup after loading the view.
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note: )), name: UIResponder.keyboardWillHideNotification, object: nil)
        DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])
        
        //Refreshing capabilities
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
    }
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()

        selectedPost.add(comment, forKey: "comment")

        selectedPost.saveInBackground {(success, error) in
            if success{
                print ("Comment Saved Dinaol!")
            } else{
                print ("Error saving comment Dinaol!")
            }
        }
        tableView.reloadData()
        // clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comment", "comment.author"])
        query.limit = 20
        query.findObjectsInBackground { (post, error) in
            if post != nil {
                self.posts = post!
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comment"] as? [PFObject]) ?? []
//         In each section their is going to be 1 picture and all the comments assocciated
//         with that picture


        return comments.count + 2
//        return posts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comment"] as? [PFObject]) ?? []
        

        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier:    "PostCell") as! PostCell
            let actualPost = posts[indexPath.row]
            let user = actualPost["author"] as! PFUser
            cell.postUserLabel.text = user.username
            cell.commentLabel.text = (actualPost["caption"] as! String)
            let imageFile = actualPost["image"] as! PFFileObject
            let urlString = imageFile.url!
            let urlFromString = URL(string: urlString)!
            
            cell.postImageView.af_setImage(withURL: urlFromString)

            return cell
        }else if indexPath.row <= comments.count{
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell

            let comment = comments[indexPath.row - 1]
            commentCell.commentLabel.text = (comment["text"] as! String)
            let user = comment["author"] as! PFUser
            commentCell.usernameComment.text = user.username
            return commentCell
        }else {
            let addCommentCell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return addCommentCell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comment"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
    }
    
    
    @IBAction func didTapLogOut(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginViewController
        print("Logged Out")
        
        
    }
    
    @objc func onRefresh() {
        run(after: 2) {
            self.refreshControl.endRefreshing()
        }
        tableView.reloadData()
    }
    func run(after wait: TimeInterval, closure: @escaping () -> Void){
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
        
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
