//
//  BaseViewController.swift
//  githubApp
//
//  Created by yongmin lee on 10/9/21.
//

import UIKit
import JGProgressHUD
import Loaf

class BaseViewController: UIViewController {
    
    //MARK: properties
    var isShowingMessage = false
    
    //MARK: UI
    var hud = JGProgressHUD(style: .dark)
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: loading methods
    func showLoading() {
        DispatchQueue.main.async {
            self.hud.show(in: self.view , animated: true)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.hud.dismiss(animated: true)
        }
    }
    
    //MARK: ToastMessage methods
    func showToastMessage(message: String){
        DispatchQueue.main.async {
            Loaf(message, state: .success, location: .top, sender: self).show(.custom(1))
        }
    }
    
    func showErrorToastMessage(message : String) {
        
        DispatchQueue.main.async {
            Loaf(message, state: .error, location: .top, sender: self).show(.custom(1))
        }
    }
    
    //MARK: Auth methods
    func isLoggedIn() -> Bool {
        // 토큰 저장여부를 통해 로그인 상태 여부 함수
        if let _ = UserDefaults.standard.object(forKey: AuthManager.ACCESS_TOKEN_KEY) as? String {
            return true // 로그인 상태
        }
        else {
            return false // 로그아웃 상태
        }
    }
    
    func setupNotiObserver() {
        // 깃헙로그인으로부터 돌아왔을때 발생하는 로그인 성공 notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidSaveAccessToken), name: NSNotification.Name(rawValue: AuthManager.SUCCESS_GET_TOKEN_USER_INFO), object: nil)
        // 깃헙로그인으로부터 돌아왔을때 발생하는 로그인 실패 notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(handleFailSaveAccessToken), name: NSNotification.Name(rawValue: AuthManager.FAIL_GET_TOKEN_USER_INFO), object: nil)
    }
    
    func setupAuthButton(){
        // access token이 있는지 체크하여 로그인/로그아웃버튼 설정
        if isLoggedIn() {
            setupLogoutButton() // access token 있으면 로그아웃 버튼 세팅
        }
        else {
            setupLoginButton() // access token 없으면 로그인 버튼 세팅
        }
    }
    
    func setupLoginButton(){
        navigationItem.rightBarButtonItem = nil
        let loginButton = UIBarButtonItem(image: #imageLiteral(resourceName: "loginIcon") , style: .plain, target: self, action: #selector(didClickedLoginButton))
        navigationItem.rightBarButtonItem =  loginButton
    }
    
    func setupLogoutButton(){
        navigationItem.rightBarButtonItem = nil
        let logoutButton = UIBarButtonItem(image: #imageLiteral(resourceName: "logoutIcon") , style: .plain, target: self, action: #selector(didClickedLoutOutButton))
        navigationItem.rightBarButtonItem =  logoutButton
    }
    
    @objc func didClickedLoginButton() {
        // 로그인버튼 클릭시 호출되는 함수 -> Override 하여 사용
    }
    
    @objc func didClickedLoutOutButton(){
        setupLoginButton() // 로그아웃 이후 authbutton은 로그인버튼으로 설정
        showToastMessage(message: "로그아웃 성공")
    }
    
    @objc func handleDidSaveAccessToken() {
        setupLogoutButton() // 로그인 이후 authbutton은 로그아웃 버튼으로 설정
    }
    
    @objc func handleFailSaveAccessToken() {
    }
}
