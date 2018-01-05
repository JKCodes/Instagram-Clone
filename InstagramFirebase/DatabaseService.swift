//
//  DatabaseService.swift
//  SocialShare
//
//  Created by Joseph Kim on 2/13/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation
import FirebaseDatabase

typealias DataSnapshotCompletion = (_ metadata: DataSnapshot) -> Void
typealias DatabaseReferenceCompletion = (_ errorMsg: String?, _ ref: DatabaseReference?) -> Void

fileprivate let FIR_CHILD_USERS = "users"
fileprivate let FIR_CHILD_USERNAMES = "usernames"
fileprivate let FIR_CHILD_PROFILE = "profile"
fileprivate let FIR_CHILD_MESSAGES = "messages"
fileprivate let FIR_CHILD_USER_MESSAGES = "user-messages"
fileprivate let FIR_CHILD_POSTS = "posts"
fileprivate let FIR_CHILD_FOLLOWING = "following"
fileprivate let FIR_CHILD_COMMENTS = "comments"
fileprivate let FIR_CHILD_LIKES = "likes"

enum DataTypes: String {
    case user
    case username
    case message
    case post
    case userMessages
    case following
    case comments
    case like
}


class DatabaseService {
    private static let _shared = DatabaseService()
    
    static var shared: DatabaseService {
        return _shared
    }
    
    var rootRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var usersRef: DatabaseReference {
        return rootRef.child(FIR_CHILD_USERS)
    }
    
    var usernamesRef: DatabaseReference {
        return rootRef.child(FIR_CHILD_USERNAMES)
    }
    
    var messagesRef: DatabaseReference {
        return rootRef.child(FIR_CHILD_MESSAGES)
    }
    
    var userMessagesRef: DatabaseReference {
        return rootRef.child(FIR_CHILD_USER_MESSAGES)
    }
    
    var postsRef: DatabaseReference {
        return rootRef.child(FIR_CHILD_POSTS)
    }
    
    var followingRef: DatabaseReference {
        return rootRef.child(FIR_CHILD_FOLLOWING)
    }
    
    var commentsRef: DatabaseReference {
        return rootRef.child(FIR_CHILD_COMMENTS)
    }
    
    var likesRef: DatabaseReference {
        return rootRef.child(FIR_CHILD_LIKES)
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
    
    func saveData(type: DataTypes, data: Dictionary<String, AnyObject>, firstChild: String?, secondChild: String?, appendAutoId: Bool, fan: Bool = false, onComplete: DatabaseReferenceCompletion?) {
        guard var ref = getRef(type: type, firstChild: firstChild, secondChild: secondChild, fan: fan) else { return }
        
        if appendAutoId {
            ref = ref.childByAutoId()
        }
        
        ref.updateChildValues(data) { [weak self] (error, ref) in
            if error != nil {
                onComplete?("Error saving data to the database", nil)
            }
    
            if fan {
                self?.saveFanData(childRef: ref, firstChild: firstChild, secondChild: secondChild, onComplete: onComplete)
            } else {
                onComplete?(nil, ref)
            }
        }
    }
    
    fileprivate func saveFanData(childRef: DatabaseReference, firstChild: String?, secondChild: String?, onComplete: DatabaseReferenceCompletion?) {
        guard let first = firstChild, let second = secondChild else { return }
        
        let senderRef = childRef.child(first).child(second)
        let receiverRef = childRef.child(second).child(first)
        
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
    func retrieveOnce(type: DataTypes, eventType: DataEventType, firstChild: String?, secondChild: String?, propagate: Bool?, sortBy: String?, onComplete: DataSnapshotCompletion?) {
        guard let ref = getRef(type: type, firstChild: firstChild, secondChild: secondChild) else { return }
        
        let sort = sortBy ?? ""
        let prop = checkProp(propagate: propagate, secondChild: secondChild)
        
        
        if prop {
            retrieveFanObjects(childRef: ref, eventType: eventType, sortBy: sort, onComplete: onComplete)
        } else {
            if sort == "" {
                ref.observeSingleEvent(of: eventType, with: { (snapshot) in
                    
                    onComplete?(snapshot)
                    
                }, withCancel: nil)
            } else {
                ref.queryOrdered(byChild: sort).observeSingleEvent(of: eventType, with: { (snapshot) in
                    
                    onComplete?(snapshot)
                    
                }, withCancel: nil)
            }
        }
    }
    
    /// For complex retrievals such as user-messages (one or two level search) and a retrieval of group of users or messages (one level search)
    /// Propagation is used to retrieve second set of data after concluding the first set of data.
    func retrieve(type: DataTypes, eventType: DataEventType, firstChild: String?, secondChild: String?, propagate: Bool?, sortBy: String?, onComplete: DataSnapshotCompletion?) {
        guard let ref = getRef(type: type, firstChild: firstChild, secondChild: secondChild) else { return }
        
        let sort = sortBy ?? ""
        
        let prop = checkProp(propagate: propagate, secondChild: secondChild)
        
        if prop {
            retrieveFanObjects(childRef: ref, eventType: eventType, sortBy: sort, onComplete: onComplete)
        } else {
            if sort == "" {
                ref.observe(eventType, with: { (snapshot) in
                    onComplete?(snapshot)
                }, withCancel: nil)
            } else {
                ref.queryOrdered(byChild: sort).observe(eventType, with: { (snapshot) in
                    onComplete?(snapshot)
                }, withCancel: nil)
            }
        }
    }
    
    // For unknown toId
    fileprivate func retrieveFanObjects(childRef: DatabaseReference, eventType: DataEventType, sortBy: String, onComplete: DataSnapshotCompletion?) {
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
    func remove(type: DataTypes, firstChild: String?, secondChild: String?, onComplete: DatabaseReferenceCompletion?) {
        guard let ref = getRef(type: type, firstChild: firstChild, secondChild: secondChild) else { return }
        
        ref.removeValue { (error, ref) in
            if error != nil {
                onComplete?("There was a problem handling the deletion request.  Please try again.", nil)
            }
            
            onComplete?(nil, ref)
        }
    }
    
    // Used to get refs for retrievals and removals
    fileprivate func getRef(type: DataTypes, firstChild: String?, secondChild: String?, fan: Bool = false) -> DatabaseReference? {
        let first = firstChild ?? ""
        let second = secondChild ?? ""
        
        var ref: DatabaseReference
        
        switch type {
        case .user: ref = usersRef
        case .message: ref = messagesRef
        case .username: ref = usernamesRef
        case .userMessages: ref = userMessagesRef
        case .post: ref = postsRef
        case .following: ref = followingRef
        case .comments: ref = commentsRef
        case .like: ref = likesRef
        }
        
        if fan {
            return ref
        }
        
        if first != "" && second != "" {
            return ref.child(first).child(second)
        } else if first != "" {
            return ref.child(first)
        } else {
            return ref
        }
    }
    
    fileprivate func checkProp(propagate: Bool?, secondChild: String?) -> Bool {
        let prop = propagate ?? false
        let second = secondChild ?? ""
        
        return second == "" ? prop : false
    }
}


