//
//  SectionModel.swift
//  githubApp
//
//  Created by yongmin lee on 10/10/21.
//

import Foundation
import RxDataSources

struct RepositorySectionModel {
    var items: [Repository]
}

extension RepositorySectionModel : SectionModelType {
    typealias Item = Repository
    
    init(original: RepositorySectionModel, items: [Repository]) {
        self = original
        self.items = items
    }
}

