//
//  DatabaseService.swift
//  SocialShare
//
//  Created by Joseph Kim on 2/13/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation
import FirebaseDatabase

typealias DataSnapshotCompletion = (_ metadata: FIRDataSnapshot) -> Void
typealias DatabaseReferenceCompletion = (_ errorMsg: String?, _ ref: FIRDatabaseReference?) -> Void

fileprivate let FIR_CHILD_USERS = "users"
fileprivate let FIR_CHILD_USERNAMES = "usernames"
fileprivate let FIR_CHILD_PROFILE = "profile"
fileprivate let FIR_CHILD_MESSAGES = "messages"
fileprivate let FIR_CHILD_USER_MESSAGES = "user-messages"
fileprivate let FIR_CHILD_POSTS = "posts"

enum DataTypes {
    case user
    case username
    case message
    case post
    case userMessages
}


class DatabaseService {
    private static let _shared = DatabaseService()
    
    static var shared: DatabaseService {
        return _shared
    }
    
    var rootRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var usersRef: FIRDatabaseReference {
        return rootRef.child(FIR_CHILD_USERS)
    }
    
    var usernamesRef: FIRDatabaseReference {
        return rootRef.child(FIR_CHILD_USERNAMES)
    }
    
    var messagesRef: FIRDatabaseReference {
        return rootRef.child(FIR_CHILD_MESSAGES)
    }
    
    var userMessagesRef: FIRDatabaseReference {
        return rootRef.child(FIR_CHILD_USER_MESSAGES)
    }
    
    var postsRef: FIRDatabaseReference {
        return rootRef.child(FIR_CHILD_POSTS)
    }
    
    func isUsernameUnique(username: String, onComplete: @escaping (_ flag: Bool) -> Void) {
        usernamesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(username) {
                onComplete(false)
            } else {
                onComplete(true)
            }
        }, withCancel: nil)
    }
    
    func saveData(uid: String?, type: DataTypes, data: Dictionary<String, AnyObject>, fan: Bool = false, onComplete: DatabaseReferenceCompletion?) {
        guard let currentId = AuthenticationService.shared.currentId() else { fatalError("This app requires users to be logged in before saving any data") }
        
        let id = uid ?? currentId
        let uniqueRef: FIRDatabaseReference
        
        switch type {
        case .message, .userMessages: uniqueRef = messagesRef.childByAutoId()
        case .user: uniqueRef = usersRef.child(id)
        case .username: uniqueRef = usernamesRef
        case .post: uniqueRef = postsRef.child(id).childByAutoId()
        }
        
        uniqueRef.updateChildValues(data) { [weak self] (error, ref) in
            if error != nil {
                onComplete?("Error saving data to the database", nil)
            }
    
            if fan {
                self?.saveFanData(childRef: uniqueRef, data: data, onComplete: onComplete)
            } else {
                onComplete?(nil, ref)
            }
        }
    }
    
    fileprivate func saveFanData(childRef: FIRDatabaseReference, data: Dictionary<String, AnyObject>, onComplete: DatabaseReferenceCompletion?) {
        guard let fromId = data["fromId"] as? String, let toId = data["toId"] as? String else { return }
        
        let senderRef = userMessagesRef.child(fromId).child(toId)
        let receiverRef = userMessagesRef.child(toId).child(fromId)
        
        let typeId = childRef.key
        
        senderRef.updateChildValues([typeId: 1]) { (error, ref) in
            if error != nil {
                onComplete?("Error saving data to the database", nil)
            }
        
            receiverRef.updateChildValues([typeId: 1]) { (error, _) in
                if error != nil {
                    onComplete?("Error saving data to the database", nil)
                }
                
                onComplete?(nil, ref)
            }
        }
    }
    
    /// For simple retrieval such as a single message or a user
    func retrieveOnce(queryString: String = "", type: DataTypes, eventType: FIRDataEventType = .value, sortBy: String = "", onComplete: DataSnapshotCompletion?) {
        guard let currentId = AuthenticationService.shared.currentId() else { return }
        
        let ref: FIRDatabaseReference
        
        switch type {
        case .user: ref = queryString != "" ? usersRef.child(queryString) : usersRef
        case .message: ref = queryString != "" ? messagesRef.child(queryString) : messagesRef
        case .username: ref = queryString != "" ? usernamesRef.child(queryString) : usernamesRef
        case .post: ref = queryString != "" ? postsRef.child(queryString) : postsRef
        case .userMessages: ref = queryString != "" ? userMessagesRef.child(currentId).child(queryString) : userMessagesRef
        }
        
        if sortBy == "" {
            ref.observeSingleEvent(of: eventType, with: { (snapshot) in
                
                onComplete?(snapshot)
                
            }, withCancel: nil)
        } else {
            ref.queryOrdered(byChild: sortBy).observeSingleEvent(of: eventType, with: { (snapshot) in
                
                onComplete?(snapshot)
                
            }, withCancel: nil)
        }
    }
    
    /// For complex retrievals such as user-messages (one or two level search) and a retrieval of group of users or messages (one level search)
    func retrieve(type: DataTypes, eventType: FIRDataEventType, fromId: String?, toId: String?, propagate: Bool?, sortBy: String = "", onComplete: DataSnapshotCompletion?) {
        let from = fromId ?? ""
        let to = toId ?? ""
        var prop = propagate ?? true  // if the propagation is set to false, one level searching will be used
        
        // Propagation is overriden to false if toId is not nil, for toId automatically assumes a two level search
        if to != "" {
            prop = false
        }
        
        guard let ref = getRef(type: type, fromId: from, toId: to) else { return }
        
        if type == .userMessages && prop {
            retrieveFanObjectsForUnknownToId(childRef: ref, eventType: eventType, sortBy: sortBy, onComplete: onComplete)
        } else {
            if sortBy == "" {
                ref.observe(eventType, with: { (snapshot) in
                    onComplete?(snapshot)
                }, withCancel: nil)
            } else {
                ref.queryOrdered(byChild: sortBy).observe(eventType, with: { (snapshot) in
                    onComplete?(snapshot)
                }, withCancel: nil)
            }
        }
    }
    
    // For unknown toId
    fileprivate func retrieveFanObjectsForUnknownToId(childRef: FIRDatabaseReference, eventType: FIRDataEventType, sortBy: String, onComplete: DataSnapshotCompletion?) {
        if sortBy == "" {
            childRef.observe(.childAdded, with: { (snapshot) in
                let typeId = snapshot.key
                
                childRef.child(typeId).observe(eventType, with: { (snapshot) in
                    onComplete?(snapshot)
                }, withCancel: nil)
            }, withCancel: nil)
        } else {
            childRef.queryOrdered(byChild: sortBy).observe(.childAdded, with: { (snapshot) in
                let typeId = snapshot.key
                
                childRef.child(typeId).queryOrdered(byChild: sortBy).observe(eventType, with: { (snapshot) in
                    onComplete?(snapshot)
                }, withCancel: nil)
            }, withCancel: nil)
        }
    }
    
    /// For complex removals such as user-message groups
    func remove(type: DataTypes, fromId: String?, toId: String?, onComplete: DatabaseReferenceCompletion?) {
        let from = fromId ?? ""
        let to = toId ?? ""
        
        guard let ref = getRef(type: type, fromId: from, toId: to) else { return }
        
        ref.removeValue { (error, ref) in
            if error != nil {
                onComplete?("There was a problem handling the deletion request.  Please try again.", nil)
            }
            
            onComplete?(nil, ref)
        }
    }
    
    // Used to get refs for retrievals and removals
    fileprivate func getRef(type: DataTypes, fromId: String, toId: String) -> FIRDatabaseReference? {
        guard var currentId = AuthenticationService.shared.currentId() else { return nil }
        
        if fromId != "" {
            currentId = fromId
        }
        
        var ref: FIRDatabaseReference
        
        switch type {
        case .user: ref = usersRef
        case .message: ref = messagesRef
        case .username: ref = usernamesRef
        case .userMessages: ref = userMessagesRef
        case .post: ref = postsRef
        }
        
        if fromId != "" && toId != "" {
            return ref.child(currentId).child(toId)
        } else if fromId != "" {
            return ref.child(currentId)
        } else {
            return ref
        }
    }
}


