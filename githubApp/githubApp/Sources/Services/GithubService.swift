//
//  GithubService.swift
//  githubApp
//
//  Created by yongmin lee on 10/9/21.
//

import Foundation
import Alamofire
import RxSwift

// 검색결과가 없는 경우 발생하는 에러
struct NoResultError : Error {
    var errorDescription : String
}

class GithubService {
    
    //MARK: properties
    static let shared = GithubService()
    
    //MARK: mehtods
    // accessToken으로 헤더설정
    func setHeader() -> HTTPHeaders {
        var accessToken = ""
        if let token = UserDefaults.standard.object(forKey: AuthService.ACCESS_TOKEN_KEY) as? String {
            accessToken = token
        }
        let header : HTTPHeaders = [
            "Authorization": "token \(accessToken)"
        ]
        return header
    }
    
    
    //MARK: Repository API
    // 레포지토리 검색 api
    func searchRepositories(query:String, page : Int) -> Observable<RepoSearchResponse> {
        // query : 검색어
        // page : 결과 페이지 번호
        
        let url = "https://api.github.com/search/repositories"
        let parameters : Parameters = [
            "q" : query,
            "page" : page
        ]
        
        return Observable.create {  emitter in
            AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: nil).responseJSON { response in
                switch response.result{
                case .success:
                    guard let result = response.data else {return}
                    do {
                        let decoder = JSONDecoder()
                        let repoSearchResponse = try decoder.decode(RepoSearchResponse.self, from: result)
                        emitter.onNext(repoSearchResponse)
                    }
                    catch {
                        emitter.onError(error)
                    }
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    // 나의 레포지토리 가져오기 api
    func getMyRepositories(page : Int)  -> Observable<[Repository]> {
        let url = "https://api.github.com/user/repos"
        let header = setHeader()
        let parameters : Parameters = [
            "page" : page,
            "type" : "all",
            "per_page" : 30
        ]
        
        return Observable.create {  emitter in
            AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: header).responseJSON { response in
                switch response.result{
                case .success:
                    guard let result = response.data else {return}
                    do {
                        let decoder = JSONDecoder()
                        let myRepoList = try decoder.decode([Repository].self , from: result)
                        emitter.onNext(myRepoList)
                    }
                    catch {
                        emitter.onError(error)
                    }
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    // fullname을 가진 repository detail 정보 가져오기
    func getRepositoryDetail(repoFullName : String) -> Observable<Repository> {
        let url = "https://api.github.com/repos/" + repoFullName
        let header = setHeader()
        return Observable.create {  emitter in
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { response in
                switch response.result{
                case .success:
                    guard let result = response.data else {return}
                    do {
                        let decoder = JSONDecoder()
                        let repoDetail = try decoder.decode(Repository.self, from: result)
                        emitter.onNext(repoDetail)
                    }
                    catch {
                        emitter.onError(error)
                    }
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    // 레포지토리 star 여부 체크 api
    func checkIsStarredRepository(repoFullName : String) -> Observable<Bool>  {
        let url = "https://api.github.com/user/starred/" + repoFullName
        let header = setHeader()
        
        return Observable.create {  emitter in
            
            AF.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { response in
                switch response.result{
                case .success:
                    if response.data == nil {
                        emitter.onNext(true)
                    }
                    else {
                        emitter.onNext(false)
                    }
                case .failure:
                    emitter.onNext(false)
                }
            }
            return Disposables.create()
        }
    }
    
    // 레포지토리 star api
    func starRepository(repoFullName : String)  -> Observable<Bool>  {
        let url = "https://api.github.com/user/starred/" + repoFullName
        let header = setHeader()
        return Observable.create {  emitter in
            AF.request(url, method: .put , parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { response in
                switch response.result{
                case .success:
                    emitter.onNext(true)
                case .failure:
                    emitter.onNext(false)
                }
            }
            return Disposables.create()
        }
    }
    
    // 레포지토리 unstar api
    func unStarRepository(repoFullName : String)  -> Observable<Bool>  {
        let url = "https://api.github.com/user/starred/" + repoFullName
        let header = setHeader()
        return Observable.create {  emitter in
            AF.request(url, method: .delete , parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { response in
                switch response.result{
                case .success:
                    emitter.onNext(true)
                case .failure:
                    emitter.onNext(false)
                }
            }
            return Disposables.create()
        }
    }
}
