//
//  AddTopicCell.swift
//  ChitChat
//
//  Created by Tomer Buzaglo on 07/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddTopicCell: UITableViewCell {
    @IBOutlet weak var topicText: UITextField!
    
    @IBAction func addTopic(_ sender: UIButton) {
        //get the text:
        let topicName = topicText.text ?? ""
        
        //ref to the database, Topics Table:
        //a new row ref in the topics table
        let ref = Database.database().reference(withPath: "Topics").childByAutoId()
        //get the key of the new row!
        let topicId = ref.key
        
        //animate the button to rotate repeatedly
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat], animations: {
            sender.transform = CGAffineTransform(rotationAngle: .pi)
        }) { (completed) in }
        
        //No User no Game.
        guard let user = Auth.auth().currentUser else {
            fatalError("No User No You!")
        }
        
        let userId = user.uid
        let userName =  (user.email ?? "Your@gmail.com").components(separatedBy: "@")[0]
    
        let topicJson = Topic(name: topicName, id: topicId, ownerId: userId, ownerName: userName).json
        
        //save the data
        ref.setValue(topicJson) { (error, ref) in
            if error == nil {
                self.topicText.text = nil
            }
            //Stop the animation
            sender.layer.removeAllAnimations()
            sender.transform = CGAffineTransform.identity
        }
    }
}








