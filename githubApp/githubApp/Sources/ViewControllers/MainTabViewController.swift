//
//  MainTabViewController.swift
//  githubApp
//
//  Created by yongmin lee on 10/9/21.
//

import UIKit
import Loaf

class MainTabViewController: UITabBarController {
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
    }
    
    //MARK: methods
    func setupTabBarController(){
        view.backgroundColor = .white
       
        // tab1 : searchViewController 레포검색
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem.image = UITabBarItem(tabBarSystemItem: .search, tag: 0).selectedImage
        searchVC.tabBarItem.selectedImage =  UITabBarItem(tabBarSystemItem: .search, tag: 0).selectedImage
        searchVC.tabBarItem.title = "검색"
        searchVC.navigationBar.tintColor = .black
        
        // tab2 : profileViewController 프로필
        let profileVC =  UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem.image = UITabBarItem(tabBarSystemItem: .contacts, tag: 0).selectedImage
        profileVC.tabBarItem.selectedImage = UITabBarItem(tabBarSystemItem: .contacts, tag: 0).selectedImage
        profileVC.tabBarItem.title = "프로필"
        profileVC.navigationBar.tintColor = .black
        
        // register tab
        viewControllers = [searchVC, profileVC]
        tabBar.tintColor = .black
        selectedIndex = 0
    }
}
