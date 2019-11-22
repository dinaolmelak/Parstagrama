//
//  FeedViewController.swift
//  Parstagrama
//
//  Created by Dinaol Melak on 11/18/19.
//  Copyright © 2019 Dinaol Melak. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var posts = [PFObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = 20
        query.findObjectsInBackground { (post, error) in
            if post != nil {
                self.posts = post!
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:    "PostCell") as! PostCell
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        cell.postUserLabel.text = user.username
        cell.commentLabel.text = (post["caption"] as! String)
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let urlFromString = URL(string: urlString)!
        
        cell.postImageView.af_setImage(withURL: urlFromString)
        
        return cell
    }
    @IBAction func didTapLogOut(_ sender: Any) {
        PFUser.logOut()
        dismiss(animated: true, completion: nil)
        print("Logged Out")
        
        
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
