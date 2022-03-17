//
//  IntroViewController.swift
//  githubApp
//
//  Created by yongmin lee on 10/8/21.
//

import UIKit

class IntroViewController: BaseViewController {

    //MARK: UI
    var logoImageView = UIImageView()   // 로고 이미지뷰
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup ui
        setupLogoImageView()
        
        // MainTabViewController 이동
        goMainTabViewController()
    }
    
    //MARK: methods
    func setupLogoImageView(){
        // logoImageView 설정
        logoImageView.backgroundColor = .clear
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = #imageLiteral(resourceName: "githubIcon")
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        // logoImageView layout
        view.addSubview(logoImageView)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive =  true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    
    // MainTabViewController 이동
    func goMainTabViewController() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            let controller = self.DIContainer.resolve(MainTabViewController.self)!
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
    }
}

