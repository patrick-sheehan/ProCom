//
//  Group.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Group: NSObject {
    
    // The name of this Group
    // ex: "iOS projects", "Finances"
    var name: String?

    var objectId: String?
    
    var parentId: String?
    
    // The sub categories within this Group
    // "lazy var" because we won't create this array in memory until needed
    // ex: think common file directory structure
    lazy var subGroups = [Group]()
    
    // The Convos stored in this Group
    // Convos are actual conversations containing text, users, pictures, etc
    lazy var convos = [Convo]()
    
    override init() {
        self.name = "Fool Jackson"
    }
    
    // initialize a new Convo, given an appropriate title
    init(name: String, parentId: String) {
        self.name = name
        self.parentId = parentId
        super.init()
    }
    
    init(networkObjectId: String) {
        super.init()
        
        var query = PFQuery(className: "Group")
        if let groupObject = query.getObjectWithId(networkObjectId) {
        
//        query.getObjectInBackgroundWithId(networkObjectId) {
//            (groupObject: PFObject!, error: NSError!) -> Void in
//            if error == nil {
                NSLog("Successfully retrieved group from the network")
                
                self.name = groupObject["name"] as? String
                self.objectId = groupObject.objectId
                self.parentId = groupObject["parentId"] as? String
                let subGroups = groupObject["subGroups"] as [String]
                
//                for subGroupId in subGroups {
//                    let subGroup = Group(networkObjectId: subGroupId)
//                    self.subGroups.append(subGroup)
//                }
            }
            else {
                NSLog("Failed to retrieve group from the network")
            }
        
    }
    
    func saveToNetwork() {
        
        var groupObject = PFObject(className: "Group")
        groupObject["name"] = self.name
        groupObject["parent"] = self.parentId
        groupObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                NSLog("Saved new group to the network")
            }
            else {
                NSLog("Failed to save new group: %@", error.description)
            }
        }
    }
    
    func addSubGroup(group: Group) {
        
        // TODO: sync with Parse here
        
        self.subGroups.append(group)
    }
    
    // TODO: a Group might like to know it's "lineage" that can be displayed to the user, like a file path
    // ex: Abraid/iOS/ProCom/...
}
