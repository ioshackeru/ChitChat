//
//  TopicsViewController.swift
//  ChitChat
//
//  Created by Tomer Buzaglo on 07/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TopicsViewController: UITableViewController {
    
    var topics = [Topic]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        tableView.rowHeight = 60
        
        Database.database().reference().child("Topics").observe(.childAdded, with: { (snapshot) in
            guard let topic = Topic(snapshot) else{
                print("Error with data - Not Json")
                return
            }
            
            self.topics.append(topic)
            let path = IndexPath(row: self.topics.count - 1, section: 1)
            self.tableView.insertRows(at: [path], with: .top)
        }){ (error) in
            print(error)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? 1 : topics.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        if section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addTopic", for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! TopicCell
        let topic = topics[indexPath.row]
        cell.topicLabel.text = topic.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get the topic:
        let topic = topics[indexPath.row]
        
        performSegue(withIdentifier: "goChat", sender: topic)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ChatController,
            let topic = sender as? Topic{
            
            dest.topic = topic
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {return false}
        
        
        let topic = topics[indexPath.item]
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        return topic.ownerId == uid
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //...
            let topic = topics[indexPath.row]
            //1) remove the topic from the array.
            topics.remove(at: indexPath.row)
            
            //2) remove the topic from firebase.
            let ref = Database.database().reference(withPath: "Topics").child(topic.id)
            ref.removeValue()
            
            //remove all the chat messages from the database.
            Database.database().reference(withPath: "ChatMessages").child(topic.name).removeValue()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
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
