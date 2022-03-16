//
//  Repository.swift
//  githubApp
//
//  Created by yongmin lee on 10/10/21.
//

import Foundation
import RxDataSources

struct Repository : Codable {
    var id : Int
    var node_id : String
    var name : String
    var full_name : String
    var owner : User 
    var description : String? 
    var stargazers_count : Int  // star 수
    var forks_count : Int       // 포크 수
    var html_url : String       // 레포지토리 깃헙 url
}

