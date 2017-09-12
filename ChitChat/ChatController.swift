//
//  ChatController.swift
//  ChitChat
//
//  Created by Tomer Buzaglo on 11/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit

import JSQMessagesViewController
import FirebaseAuth
import FirebaseDatabase

class ChatController: JSQMessagesViewController {
    var messages:[JSQMessage] = []
    
    var messageRef: DatabaseReference! // explicitly unwrapped.
    
    var topic:Topic!{
        didSet{
            print(topic)
            messageRef = Database.database().reference(withPath: "ChatMessages").child(topic.name)
        }
    }
    
    var userName:String{
        return user.email?.components(separatedBy: "@")[0] ?? ""
    }
    var user:User!{
        return Auth.auth().currentUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Who am I?
        self.senderId = user.uid
        //Tomerbu@gmail.com
        self.senderDisplayName = userName
        
        messageRef.observe(.childAdded, with: { (snapshot) in
            guard let message = JSQMessage(snapshot: snapshot) else {return}
            
            //add the message to the messages.
            self.messages.append(message)
            
            //notify the collectionview about the new row
            self.finishReceivingMessage()
        })
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        self.navigationItem.title = topic.name
        
//        let iv = UIImageView(image: #imageLiteral(resourceName: "whatsapp"))
//        
//        
//        self.view.insertSubview(iv, at: 0)
//        collectionView.backgroundColor = UIColor.clear
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    //messageBubbleImageDataForItemAt
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        
        let factory = JSQMessagesBubbleImageFactory()
        
        let incoming = factory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        let out = factory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
        //if im the sender -> let it be gray, else let it be blue
        let message = messages[indexPath.item]
        let senderId = message.senderId
        
        return senderId == user.uid ? out : incoming
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        //1) init a new Message
        guard let message = JSQMessage(senderId: user.uid,
                                       senderDisplayName: userName,
                                       date: Date(),
                                       text: text) else {return}
        
        
        
        
        //2) save the message to the reference:
        messageRef.childByAutoId().setValue(message.json)
        
        //3) tell the collection view about the new message
        finishSendingMessage()
        
        //play a nice sound!
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
    }
    
    
    //attributed Text For Message BubbleTopLabelAt
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        //convert the display name to NSAttributed String
        let name = NSAttributedString(string: message.senderDisplayName)
        
        return message.senderId == user.uid ? NSAttributedString(string: "You") : name
    }
    
    //heightForMessageBubbleTopLabelAt
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 20
    }
    
    //date
    
    //bottomlabel
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium //pre baked sizes for the dates.
        formatter.timeStyle = .short
        
        formatter.doesRelativeDateFormatting = true //today! yesterday :)
        
        
        let date = formatter.string(from: message.date)
        
        return NSAttributedString(string: date)
    }
    //bottomlabel
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 20
    }
}












//Add toJson and init?(DataSnapshot)
extension JSQMessage{
    var json: [String: Any]{
        return [
            "senderId" : self.senderId,
            "senderDisplayName" : self.senderDisplayName,
            "text" : self.text,
            "date" : self.date.timeIntervalSince1970 * 1000
        ]
    }
    
    convenience init?(snapshot:DataSnapshot){
        
        guard let json = snapshot.value as? [String: Any],
            let senderId = json["senderId"] as? String,
            let senderDisplayName = json["senderDisplayName"] as? String,
            let text = json["text"] as? String,
            let dateInterval = json["date"] as? TimeInterval
            else {return nil}
        
        
        let date = Date(timeIntervalSince1970: dateInterval / 1000)
        self.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
    }
}

extension TimeInterval{
    var millis:Double{
        return self * 1000
    }
    
    init(_ millis: TimeInterval){
        self.init(millis / 1000)
    }
}











