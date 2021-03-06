//
//  AuthService.swift
//  githubApp
//
//  Created by yongmin lee on 10/9/21.
//

import UIKit
import Alamofire
import RxSwift

class AuthService {
    
    //MARK: properties
    static let shared = AuthService()
    static let SUCCESS_GET_TOKEN_USER_INFO = "SUCCESS_GET_TOKEN_USER_INFO"
    static let FAIL_GET_TOKEN_USER_INFO = "FAIL_GET_TOKEN_USER_INFO"
    static let ACCESS_TOKEN_KEY = "ACCESS_TOKEN_KEY"
    static let USER_INFO_KEY = "USER_INFO_KEY"
    private let clientId = "9a7db04c7cc087570876"
    private let clientSecret = "7347197360af119cf2914a5869b696c636d65a6d"
    
    //MARK: methods
    func getUserCode() {
        let scope = "repo,user"
        let urlString = "https://github.com/login/oauth/authorize?client_id=\(clientId)&scope=\(scope))"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)  // 깃헙로그인 open
    }
    
    func getAccessTokenAndUserInfo(code : String) {
        let url = "https://github.com/login/oauth/access_token"
        // 헤더 설정
        let header : HTTPHeaders = [
            "Accept" :  "application/json"
        ]
        // 파라미터 설정
        let parameters : Parameters = [
            "client_id" : clientId ,
            "client_secret" : clientSecret  ,
            "code" : code
        ]
        
        AF.request(url, method: .post, parameters: parameters, headers: header).responseJSON { response in
            switch response.result{
            case .success:
                guard let result = response.data else {return}
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(AccessTokenResponse.self, from: result)
                    guard let token = decodedData.access_token else { return }
                    // token 으로 서버에서 UserInfo 가져오기
                    self.getUserInfo(withToken: token)
                }
                catch {
                    self.failGetTokenAndUserInfo()
                }
            case .failure:
                self.failGetTokenAndUserInfo()
            }
        }
    }
    
    func getUserInfo(withToken accessToken : String){
        let url = "https://api.github.com/user"
        // 헤더 설정
        let header : HTTPHeaders = [
            "Accept": "application/vnd.github.v3+json",
            "Authorization": "token \(accessToken)"
        ]
        // get user info
        AF.request(url, method: .get, parameters: nil, headers: header).responseJSON  { response in
            switch response.result{
            case .success:
                guard let result = response.data else {return}
                do {
                    // reponse안의 json data를 User 모델에 맞게 파싱
                    let decoder = JSONDecoder()
                    let userInfo = try decoder.decode(User.self, from: result)
                    self.saveAccessToken(token: accessToken)    // token 저장
                    self.saveUserInfo(user: userInfo)           // userinfo 저장
                    // 로그인이 완료 되었음을 notification post
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: AuthService.SUCCESS_GET_TOKEN_USER_INFO) , object: nil, userInfo: nil)
                }
                catch {
                    self.failGetTokenAndUserInfo()
                }
            case .failure:
                self.failGetTokenAndUserInfo()
            }
        }
    }
    
    func saveUserInfo(user : User){
        let userDictionary : [String:String] = [
            "id" : "\(user.id)",
            "login" : user.login,
            "avatar_url" : user.avatar_url,
            "followers" : "\(user.followers ?? 0)",
            "following" : "\(user.following ?? 0)"
        ]
        // save UserInfo
        UserDefaults.standard.setValue(userDictionary, forKey: AuthService.USER_INFO_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func saveAccessToken(token : String){
        // save AccessToken
        UserDefaults.standard.setValue(token, forKey: AuthService.ACCESS_TOKEN_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func failGetTokenAndUserInfo(){
        // // 로그인 실패 notification post
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AuthService.FAIL_GET_TOKEN_USER_INFO) , object: nil, userInfo: nil)
    }
    
    func removeAccessToken() {
        // UserDefaults의 유저정보 삭제
        UserDefaults.standard.removeObject(forKey: AuthService.ACCESS_TOKEN_KEY)
        UserDefaults.standard.removeObject(forKey: AuthService.USER_INFO_KEY)
    }
}
