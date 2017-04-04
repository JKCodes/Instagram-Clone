//
//  CustomTabBarController.swift
//  FacebookFeedClone
//
//  Created by Joseph Kim on 3/23/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AuthenticationService.shared.currentId() == nil {
            DispatchQueue.main.async { [weak self] in
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self?.present(navController, animated: true, completion: nil)
            }
            
            return
        }
        
        setupViewControllers()
    }
    
    func setupViewControllers() {
        let layout = UICollectionViewFlowLayout()
        let userProfileVC = UserProfileController(collectionViewLayout: layout)
        userProfileVC.navigationItem.title = "Temp"
        let userProfileViewController = UINavigationController(rootViewController: userProfileVC)
        userProfileViewController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfileViewController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        viewControllers = [createTemporaryController(title: "Home", image: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())),
                           createTemporaryController(title: "Search", image: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected")),
                           createTemporaryController(title: "Add", image: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected")),
                           createTemporaryController(title: "Like", image: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected")),
                           userProfileViewController]
        
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    fileprivate func createTemporaryController(title: String, image: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        viewController.navigationItem.title = title
        viewController.view.backgroundColor = .white
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = image
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
