//
//  RepositoryDetailViewModel.swift
//  githubApp
//
//  Created by yongmin lee on 10/12/21.
//

import Foundation
import RxSwift

class RepositoryDetailViewModel {
    
    //MARK: properties
    var disposbag : DisposeBag!
    var fullName : String
    var starSubject = BehaviorSubject(value: false)
    var nameSuject = PublishSubject<String>()
    var descriptionSuject = PublishSubject<String>()
    var ownerAvatarSuject = PublishSubject<String>()
    var ownerLoginSuject = PublishSubject<String>()
    var ownerTypeSuject = PublishSubject<String>()
    var starCountSuject = BehaviorSubject(value: 0)
    var forkCountSuject = PublishSubject<Int>()
    var htmlSuject = PublishSubject<String>()
    
    //MARK: initializer
    init(fullName : String) {
        self.fullName = fullName
    }
    
    //MARK: methods
    // fullname을 가진 repository detail 정보 가져오기
    func getRepositoryDetail() {
        GithubService.shared.getRepositoryDetail(repoFullName: fullName)
            .subscribe(onNext: { [weak self] repoDetail in
                self?.nameSuject.on(.next(repoDetail.name))
                self?.descriptionSuject.on(.next(repoDetail.description ?? ""))
                self?.ownerAvatarSuject.on(.next(repoDetail.owner.avatar_url))
                self?.ownerLoginSuject.on(.next(repoDetail.owner.login))
                self?.ownerTypeSuject.on(.next(repoDetail.owner.type ?? ""))
                self?.starCountSuject.on(.next(repoDetail.stargazers_count))
                self?.forkCountSuject.on(.next(repoDetail.forks_count))
                self?.htmlSuject.on(.next(repoDetail.html_url))
            })
            .disposed(by: self.disposbag)
    }
    
    // 내가 star체크한 레포지토리인지 여부 검사
    func checkIsStarredRepository()  {
        GithubService.shared.checkIsStarredRepository(repoFullName: self.fullName)
            .subscribe(onNext: { [weak self] isStarred in
                if isStarred == true {
                    self?.starSubject.on(.next(true))
                }
                else {
                    self?.starSubject.on(.next(false))
                }
            })
            .disposed(by: self.disposbag)
    }
    
    // 레포지토리 star, unstar toggle 함수
    func toggleStar() ->Observable<Bool> {
        let currentStarred = try? starSubject.value() // 현재 상태
        return Observable.create {  [weak self] emitter in
            // 현재 star 상태이면
            if currentStarred == true {
                // unstar 수행
                GithubService.shared.unStarRepository(repoFullName: self?.fullName ?? "")
                    .subscribe(onNext: { starred in
                        let currentStar = try? self?.starCountSuject.value()
                        let newStar = (currentStar ?? 0) - 1
                        self?.starCountSuject.on(.next(newStar))
                        self?.starSubject.on(.next(false)) // 별표 표시 지우기
                        emitter.onNext(false)
                    })
                    .disposed(by: self!.disposbag)
            }
            // 현재 unstar 상태이면
            else {
                // star 수행
                GithubService.shared.starRepository(repoFullName: self?.fullName ?? "")
                    .subscribe(onNext: {starred in
                        let currentStar = try? self?.starCountSuject.value()
                        let newStar = (currentStar ?? 0) + 1
                        self?.starCountSuject.on(.next(newStar))
                        self?.starSubject.on(.next(true)) // 별표 표시
                        emitter.onNext(true)
                    })
                    .disposed(by: self!.disposbag)
            }
            return Disposables.create()
        }
    }
}
