//
//  User.swift
//  githubApp
//
//  Created by yongmin lee on 10/10/21.
//

import Foundation

// 유저,레포지터리오너 정보
struct User : Codable {
    var id : Int            // 아이디
    var login : String      // 로그인아이디
    var avatar_url : String // 프로필 이미지
    var followers : Int?    // 팔로워 수
    var following : Int?    // 팔로잉 수 
    var type : String?      // 유저타입
}
