//
//  AppDelegate.swift
//  githubApp
//
//  Created by yongmin lee on 10/8/21.
//

import UIKit
import Swinject

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let container = Container()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerViewModel()
        registerViewController()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

//MARK: Dependency injection
extension AppDelegate {
    func registerViewModel() {
         container.register(RepositoryViewModel.self) { r in RepositoryViewModel()}
         container.register(RepositoryDetailViewModel.self) { (r:Resolver, fullName: String)  in
             RepositoryDetailViewModel(fullName: fullName)
         }
     }
     
     func registerViewController() {
         container.register(MainTabViewController.self) { r in MainTabViewController() }
         container.register(SearchViewController.self) { r in
             let vc = SearchViewController()
             vc.searchViewModel = r.resolve(RepositoryViewModel.self)
             return vc
         }
         container.register(ProfileViewController.self) { r in
             let vc = ProfileViewController()
             vc.profileViewModel = r.resolve(RepositoryViewModel.self)
             return vc
         }
         container.register(RepositoryDetailViewController.self) { (r:Resolver, fullName:String) in
             let vc = RepositoryDetailViewController()
             vc.repoDetailViewModel = r.resolve(RepositoryDetailViewModel.self, argument: fullName)
             return vc
         }
     }
}
