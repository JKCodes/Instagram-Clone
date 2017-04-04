//
//  DatabaseService.swift
//  SocialShare
//
//  Created by Joseph Kim on 2/13/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation
import FirebaseDatabase

typealias DataSnapshotCompletion = (_ metadata: FIRDataSnapshot?) -> Void
typealias DatabaseReferenceCompletion = (_ errorMsg: String?, _ ref: FIRDatabaseReference?) -> Void

fileprivate let FIR_CHILD_USERS = "users"
fileprivate let FIR_CHILD_USERNAMES = "usernames"
fileprivate let FIR_CHILD_PROFILE = "profile"
fileprivate let FIR_CHILD_MESSAGES = "messages"
fileprivate let FIR_CHILD_USER_MESSAGES = "user-messages"

enum DataTypes {
    case user
    case username
    case message
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
    
    func saveData(uid: String?, type: DataTypes, data: Dictionary<String, AnyObject>, fan: Bool = false, onComplete: DatabaseReferenceCompletion?) {
        if uid == nil && type == .user { fatalError("uid is required if a user is to be saved") }
        
        let uniqueRef: FIRDatabaseReference
        
        switch type {
        case .message, .userMessages: uniqueRef = messagesRef.childByAutoId()
        case .user: uniqueRef = usersRef.child(uid!)
        case .username: uniqueRef = usernamesRef
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
    
    func isUsernameUnique(username: String, onComplete: @escaping (_ flag: Bool) -> Void) {
        usernamesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(username) {
                onComplete(false)
            } else {
                onComplete(true)
            }
        }, withCancel: nil)
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
    func retrieveSingleObject(queryString: String, type: DataTypes, onComplete: DataSnapshotCompletion?) {
        guard let currentId = AuthenticationService.shared.currentId() else { return }
        
        let ref: FIRDatabaseReference
        
        switch type {
        case .user: ref = usersRef.child(queryString)
        case .message: ref = messagesRef.child(queryString)
        case .username: ref = usernamesRef.child(queryString)
        case .userMessages: ref = userMessagesRef.child(currentId).child(queryString)
        }
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            onComplete?(snapshot)
            
        }, withCancel: nil)
    }
    
    /// For complex retrievals such as user-messages (one or two level search) and a retrieval of group of users or messages (one level search)
    func retrieveMultiple(type: DataTypes, eventType: FIRDataEventType, fromId: String?, toId: String?, propagate: Bool?, onComplete: DataSnapshotCompletion?) {
        let from = fromId ?? ""
        let to = toId ?? ""
        var prop = propagate ?? true  // if the propagation is set to false, one level searching will be used
        
        // Propagation is overriden to false if toId is not nil, for toId automatically assumes a two level search
        if to != "" {
            prop = false
        }
        
        guard let ref = getRef(type: type, fromId: from, toId: to) else { return }
        
        if type == .userMessages && prop {
            retrieveFanObjectsForUnknownToId(childRef: ref, eventType: eventType, onComplete: onComplete)
        } else {
            ref.observe(eventType, with: { (snapshot) in
                onComplete?(snapshot)
            }, withCancel: nil)
        }
    }
    
    // For unknown toId
    fileprivate func retrieveFanObjectsForUnknownToId(childRef: FIRDatabaseReference, eventType: FIRDataEventType, onComplete: DataSnapshotCompletion?) {
        childRef.observe(.childAdded, with: { (snapshot) in
            let typeId = snapshot.key
            
            childRef.child(typeId).observe(eventType, with: { (snapshot) in
                onComplete?(snapshot)
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    /// For complex removals such as user-message groups
    func removeMultiple(type: DataTypes, fromId: String?, toId: String?, onComplete: DatabaseReferenceCompletion?) {
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
        }
        
        if type == .userMessages {
            if toId != "" {
                return ref.child(currentId).child(toId)
            } else {
                return ref.child(currentId)
            }
        } else {
            return ref
        }
    }
    
}


