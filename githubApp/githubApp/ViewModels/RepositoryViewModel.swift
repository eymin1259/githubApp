//
//  RepositoryViewModel.swift
//  githubApp
//
//  Created by yongmin lee on 2021/10/12.
//

import Foundation
import RxSwift

class RepositoryViewModel {
    //MARK: properties
    weak var disposeBag : DisposeBag!
    var repositoriesSubect = BehaviorSubject(value: [RepositorySectionModel(items: [Repository]())])
    var query = ""          // 검색어
    var currentPage = 0     // 현재 검색 페이지
    var isSearching = false // 현재 검색중인지 여부
    var isEnd = false       // 무한 스크롤 완료 여부
    
    //MARK: methods
    func login() {
        AuthManager.shared.getUserCode()
    }
    
    func logout(){
        AuthManager.shared.removeAccessToken()
    }
    
    func clearRepositories() {
        // [Repository] 비우기
        let emptySections = [
            RepositorySectionModel(items: [Repository]())
        ]
        repositoriesSubect.on(.next(emptySections))
    }
    
    // 레포지토리 검색
    func searchRepository(scrolled : Bool, query : String = "")  {
        // scrolled -> true : 무한스크롤로 레포지토리 리스트 request , false: 검색으로 레포리지토리 리스트 request
        // query : 레포지토리 검색어
        
        // 검색으로 레포리지토리 리스트 request하면
        if scrolled == false {
            // 기존 무한스크롤 정보 초기화
            clearRepositories()
            currentPage = 0
            self.query = query
            isEnd = false
        }
        
        // 마지막페이지 이거나, 지금 검색중이거나, 검색어가 비어있다면
        if  isEnd || isSearching || self.query == "" {
            return // 검색을 하지 않음 -> 중복 이미지 검색 방지
        }
        
        isSearching = true  // 검색중임을 체크 -> 중복 이미지 검색 방지
        currentPage += 1    // page 수 증가
        
        // repo search api 호출
        GithubApiManager.shared.searchRepositories(query: self.query, page: currentPage)
            .subscribe(onNext: { [weak self] response in
                // response : repo search 검색결과
                let items = response.items
                if let currentSection = try? self?.repositoriesSubect.value(), let currentRepos = currentSection.first?.items {
                    if currentRepos.count != 0 && items.count == 0 {
                        self?.isEnd = true
                        self?.isSearching = false
                        self?.repositoriesSubect.on(.next(currentSection))
                        return
                    }
                    var newRepos = currentRepos.map{$0}
                    newRepos.append(contentsOf: items)
                    let newSections  = [
                        RepositorySectionModel(items: newRepos)
                    ]
                    self?.isEnd = false
                    self?.isSearching = false
                    self?.repositoriesSubect.on(.next(newSections))
                }
            }, onError: { [weak self] error in // 검색결과가 없거나 response fail이면
                // 검색 설정값 재설정
                self?.clearRepositories()
                self?.isEnd = true
                self?.isSearching = false
            }).disposed(by: disposeBag)
    }
    
    // 나의 레포지토리 가져오기
    func getMyRepositories(scrolled : Bool) {
        // scrolled -> true : 무한스크롤로 나의 레포지토리 리스트 request , false: 초기 view 로드시 레포리지토리 리스트 request

        // 무한스크롤로 나의 레포지토리 리스트 request 하지 않으면
        if scrolled == false {
            // 기존 무한스크롤 정보 초기화
            clearRepositories()
            isEnd = false
            isSearching = false
            currentPage = 0
        }
        
        // 마지막페이지 이거나, 지금 검색중이거나, 검색어가 비어있다면
        if  isEnd || isSearching  {
            return // 검색을 하지 않음 -> 중복 이미지 검색 방지
        }
        
        isSearching = true  // 검색중임을 체크 -> 중복 이미지 검색 방지
        currentPage += 1    // page 수 증가
        
        
        GithubApiManager.shared.getMyRepositories(page: currentPage)
            .subscribe(onNext: { [weak self] myRepos in
                // myRepos 서버에서 받은 나의 레포지토리 정보
                if let currentSection = try? self?.repositoriesSubect.value(), let currentRepos = currentSection.first?.items {
                    if currentRepos.count != 0 && myRepos.count == 0 {
                        // 나의 레포지토리 모두 찾은 경우
                        self?.isEnd = true
                        self?.isSearching = false
                        self?.repositoriesSubect.on(.next(currentSection))
                        return
                    }
                    var newRepos = currentRepos.map{$0}
                    newRepos.append(contentsOf: myRepos)
                    let newSections  = [
                        RepositorySectionModel(items: newRepos)
                    ]
                    self?.repositoriesSubect.on(.next(newSections))
                    self?.isEnd = false
                    self?.isSearching = false
                }
            }, onError: {  [weak self] error in // 검색결과가 없거나 response fail이면
                // 검색 설정값 재설정
                self?.clearRepositories()
                self?.isEnd = false
                self?.isSearching = false
            }).disposed(by: disposeBag)
        
    }
    
    func getOwnerInfo() -> User? {
        guard let userDictionary = UserDefaults.standard.object(forKey: AuthManager.USER_INFO_KEY) as? [String:String] else {return nil}
        let id = userDictionary["id"] ?? "0"
        let login = userDictionary["login"] ?? ""
        let avatar_url = userDictionary["avatar_url"] ?? ""
        let followers = userDictionary["followers"] ?? "0"
        let following = userDictionary["following"] ?? "0"
        let user = User(id: Int(id) ?? 0, login: login, avatar_url: avatar_url, followers: Int(followers) ?? 0, following: Int(following) ?? 0)
        return user
    }
    
}
