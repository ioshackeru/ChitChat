//
//  Topic.swift
//  ChitChat
//
//  Created by Tomer Buzaglo on 11/09/2017.
//  Copyright © 2017 iTomerBu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Topic{
    var name: String // the name of the topic
    var id: String //topicID
    var ownerId: String //owner UID
    var ownerName:String //the name of the owner
    var date:Date // the date the topic was last changed.
    
    //designated init
    //will call super if we are inheriting from something.
    init(name:String, id:String, ownerId:String,
         ownerName:String, date:Date = Date()) {
        self.name = name
        self.id = id
        self.ownerId  = ownerId
        self.ownerName = ownerName
        self.date = date
    }
    
    //A Convenience init to handle json data.
    //conveince init must call a designated init
    convenience init?(_ snapshot: DataSnapshot) {
        
        guard let json = snapshot.value as? [String: Any],
            let name = json["name"] as? String,
            let id = json["id"] as? String,
            let ownerId = json["ownerId"] as? String,
            let ownerName = json["ownerName"] as? String,
            let date = json["date"] as? TimeInterval
            else{return nil}
        
        self.init(name: name, id: id, ownerId: ownerId,
                  ownerName: ownerName,
                  date: Date(timeIntervalSince1970: date / 1000)
        )
    }
    
    //toDictionary // toJson
    var json:[String:Any]{
        return ["name" : name,
                "id" : id,
                "ownerId":ownerId,
                "ownerName": ownerName,
                "date": date.timeIntervalSince1970 * 1000]
    }
}











