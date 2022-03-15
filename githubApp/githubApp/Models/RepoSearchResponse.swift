//
//  RepoSearchResponse.swift
//  githubApp
//
//  Created by yongmin lee on 10/10/21.
//

import Foundation

// 레포지터리 검색 결과 response
struct RepoSearchResponse : Codable {
    var total_count : Int
    var items : [Repository]
}
