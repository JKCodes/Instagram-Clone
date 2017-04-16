//
//  UserSearchController.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/16/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    fileprivate let cellId = "cellId"
    fileprivate let cellHeight: CGFloat = 66
    fileprivate let contentSpacing: CGFloat = 8
    
    lazy var searchBar: UISearchBar = { [weak self] in
        guard let this = self else { return UISearchBar() }
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(r: 230, g: 230, b: 230)
        sb.delegate = this
        sb.autocapitalizationType = .none
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: contentSpacing, bottomConstant: 0, rightConstant: contentSpacing, widthConstant: 0, heightConstant: 0)
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.alwaysBounceVertical = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchUsers()
    }
    
    fileprivate func fetchUsers() {
        
        DatabaseService.shared.retrieveOnce(type: .user) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            print(dictionaries)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: cellHeight)
    }
}
