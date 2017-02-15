//
//  FeedTableViewController.swift
//  AC3.2-Final
//
//  Created by Sabrina Ip on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase

class FeedTableViewController: UITableViewController {
    var databaseReference: FIRDatabaseReference!
    var posts = [(imageName: String, comment: String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        self.databaseReference = FIRDatabase.database().reference().child("posts")
        getPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Login if not signed in
        if FIRAuth.auth()?.currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let svc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            present(svc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPosts()
    }
    
    func getPosts() {
        databaseReference.observeSingleEvent(of: .value, with: { (snapshot) in
            var newPosts: [(imageName: String, comment: String)] = []
            for child in snapshot.children {
                if let snap = child as? FIRDataSnapshot,
                    let valueDict = snap.value as? [String:String] {
                    let imageName = snap.key
                    let comment = valueDict["comment"] ?? ""
                    newPosts.append(imageName: imageName, comment: comment)
                }
            }
            if !newPosts.isEmpty {
                self.posts = newPosts
            }
            self.tableView.reloadData()
            dump(self.posts)
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedTableViewCell

        let post = posts[indexPath.row]
        cell.commentLabel.text = post.comment
        
        let storageRef = FIRStorage.storage().reference().child("images/\(post.imageName)")
        
        storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let image = UIImage(data: data)
                cell.photoImageView.image = image
            }
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
