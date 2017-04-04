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
        
        let layout = UICollectionViewFlowLayout()
        let userProfileVC = UserProfileController(collectionViewLayout: layout)
        userProfileVC.navigationItem.title = "Temp"
        let userProfileViewController = UINavigationController(rootViewController: userProfileVC)
        userProfileViewController.title = "Profile"
        userProfileViewController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        userProfileViewController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        viewControllers = [userProfileViewController, createTemporaryController(title: "Temp", imageName: "temp"), createTemporaryController(title: "Temp", imageName: "temp"), createTemporaryController(title: "Temp", imageName: "temp"), createTemporaryController(title: "Temp", imageName: "temp")]
    }
    
    private func createTemporaryController(title: String, imageName: String) -> UINavigationController {
        let viewController = UIViewController()
        viewController.navigationItem.title = title
        viewController.view.backgroundColor = .white
        let navController = UINavigationController(rootViewController: viewController)
        navController.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
}
