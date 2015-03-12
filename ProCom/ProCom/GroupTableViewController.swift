//
//  GroupTableViewController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit


class GroupTableViewController: UITableViewController, UIAlertViewDelegate {
    
    let TEST_USER_ID = "kRaibtYs3r"
    let HOME_GROUP_ID = "fZRM5e8UVo"
    
    var user: PFUser?
    var groupArray: [Group] = []
    var convoArray: [Convo] = []
    
    // MARK: - Initialization
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.fetchGroupAndAddToArray(HOME_GROUP_ID)
        
         self.getConvosForUser(TEST_USER_ID)
        
//        if let name = self.group?.name {
//            self.navigationItem.title = name
//        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }
    
    // MARK: - Fetch Data from Parse
    func getConvosForUser(userId: String) {
        // Fetch conversations for a user
        
        let userQuery = PFQuery(className: "_User")
        
        var convos = NSArray()
        
        userQuery.getObjectInBackgroundWithId(userId, block:{(PFObject user, NSError error) in
            
            if (user != nil) {
                
                let queryConvo = PFQuery(className: "Convo")
                queryConvo.whereKey("users", equalTo: user)
                queryConvo.includeKey("groupId")
                
                queryConvo.findObjectsInBackgroundWithBlock ({
                    (array: [AnyObject]!, error: NSError!) -> Void in
                    
                    if (error != nil) {
                        NSLog("error " + error.localizedDescription)
                    }
                    else {
                        for object in array {
                            
                            if let convo = object as? Convo {
                                
                                // Add Convo to array
                                self.convoArray.append(convo)
                                var convoName: String = convo["name"] as String
                                println("Fetched convo: \(convoName)")

                                // Make sure we found its parent group
                                if let parentGroup = convo.objectForKey("groupId") as? Group {
                                    self.groupArray.append(parentGroup)
                                    
                                    var groupName: String = parentGroup["name"] as String
                                    print("Fetched group for the convo: \(groupName)")
//                                    var parentId: String = parentGroup["parent"] as String
//                                    print("\twith parent ID: \(parentId)\n")
                                    
                                }
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                })
            }
        })
    }

    
    func fetchGroupAndAddToArray(groupId: String) {
        
        let query = Group.query()
        query.includeKey(SUB_GROUP_KEY)
        query.includeKey(PARENT_GROUP_KEY)
        
        query.getObjectInBackgroundWithId(groupId, block:{(PFObject object, NSError error) in
            
            if (error == nil) {
                if let group = object as? Group {
                    
                    println("Fetched group with ID: \(groupId)")
                    
                    self.groupArray.append(group)
                    self.tableView.reloadData()
                    
                }
                
            }
            else {
                println("An error occurred while fetching group with ID: \(groupId)")
            }
        })
    }
    
    // MARK: - Send Data to Parse
    func createGroupAndSendToParse(groupName: String, parentGroupIdOrNil: String?) {
        var group = Group(name: groupName)
        group.parentId = parentGroupIdOrNil
        
        group.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if success {
                println("Successfully saved Group: \(groupName)")
                self.groupArray.append(group)
                self.tableView.reloadData()
            }
            else {
                println("An error occurred while saving Group: \(groupName)")
            }
        }
    }
    
    // MARK: - User Interface Controls

    @IBAction func addButtonPressed(sender: AnyObject) {

        // User tapped 'add' button
        
        self.promptGroupCreation()
        
    }
    
    func promptGroupCreation() {
        
        // Prompt user for name of new group
        var alertView = UIAlertView(title: "New Group", message: "Enter the title of your new group", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {

        // Made selection on UIAlertView
        
        if buttonIndex == 1 {
            if alertView.title == "New Group" {
                if let field = alertView.textFieldAtIndex(0) {
                    if let title = field.text {
                        // Make new group
                        
                        
                        var newGroup = Group(name:title, parentId: "")
                        
//                        if let parentGroup = self.group {
//                            newGroup.parentId = parentGroup.objectId
//                            parentGroup.addSubGroup(newGroup)
//                        }
//                        else {
//                            // No group assigned for this view yet. Assign the new group
//                            self.assignGroup(newGroup)
//                        }
                        
                        newGroup.saveToNetwork()
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }
  
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if section == GROUP_TABLE_VIEW_SECTION {
            return self.groupArray.count
        }

        if section == CONVO_TABLE_VIEW_SECTION {
            return self.convoArray.count
        }
        
        return 0
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            if let name = self.groupArray[indexPath.row].objectForKey("name") as? String {
                println("name: \(name)")
                cell.textLabel?.text = name
            }
        }
        
        else if indexPath.section == CONVO_TABLE_VIEW_SECTION {
            
            if let name = self.convoArray[indexPath.row].objectForKey("name") as? String {
                println("name: \(name)")
                cell.textLabel?.text = name
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            var group = self.groupArray[indexPath.row]

            
            for sub in group.subGroups {
                let subGroup: Group = sub as Group
                self.groupArray.append(subGroup)
            }
        }
        
        if indexPath.section == CONVO_TABLE_VIEW_SECTION {

            var convo = self.convoArray[indexPath.row]

        }
        
        
//        self.groupArray.removeAll(keepCapacity: false)
//        self.groupArray.extend(group.subGroups as [PFObject]!)
        
//        if let group = self.groupArray[indexPath.row] as Group {
//            
//            println("selected group: \(group)")
//            println("his subgroups: \(group.subGroups)")
//            
//            self.groupArray.removeAll(keepCapacity: false)
//            
//            self.groupArray.extend(group.subGroups as [PFObject]!)
        
//        }
        
        self.tableView.reloadData()
        
        return
    }
}
