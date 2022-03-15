//
//  AccessTokenResponse.swift
//  githubApp
//
//  Created by yongmin lee on 10/9/21.
//

import Foundation

// login/oauth/access_token api response
struct AccessTokenResponse : Codable {
    var access_token : String? // 토큰값
}
