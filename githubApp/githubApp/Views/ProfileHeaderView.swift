//
//  ProfileHeaderView.swift
//  githubApp
//
//  Created by yongmin lee on 10/11/21.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileHeaderView : UIView {
    
    //MARK: properties
    var viewModel : User?
    var disposeBag : DisposeBag!
    
    //MARK: UI
    var loginLabel = UILabel()
    var followerLabel = UILabel()
    var avatarImage = UIImageView()
    
    //MARK: initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: methods
    func setupLoginLabel() {
        // loginLabel : 유저 로그인 아이디
        loginLabel.font = .boldSystemFont(ofSize: 25)
        loginLabel.textColor = .black
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        // loginLabel layout
        addSubview(loginLabel)
        loginLabel.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor).isActive = true
        loginLabel.leftAnchor.constraint(equalTo: avatarImage.rightAnchor, constant: 30).isActive = true
    }
    
    func setupFollowerLabel() {
        // followerLabel : 유저 파로워, 팔로잉
        followerLabel.font = .boldSystemFont(ofSize: 15)
        followerLabel.textColor = .darkGray
        followerLabel.translatesAutoresizingMaskIntoConstraints = false
        // followerLabel layout
        addSubview(followerLabel)
        followerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        followerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
    }
    
    func setupAvatarImage() {
        // avatarImage : 유저 프로필이미지
        avatarImage.contentMode = .scaleAspectFill
        avatarImage.clipsToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.backgroundColor = .systemGray
        // avatarImage layout
        addSubview(avatarImage)
        avatarImage.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20).isActive = true
        avatarImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        avatarImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        avatarImage.layer.cornerRadius = 40
        avatarImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
    }
    
    
    //MARK: bind
    func bind() {
        // viewModel binding
        // loginLabel
        Observable<String>.just(viewModel?.login ?? "")
            .asDriver(onErrorJustReturn: "").drive(loginLabel.rx.text).disposed(by: disposeBag)
        // followerLabel
        Observable<String>.just("\(viewModel?.followers ?? 0) followers, \(viewModel?.following ?? 0) following").asDriver(onErrorJustReturn: "").drive(followerLabel.rx.text).disposed(by: disposeBag)
        // avatarImage
        Observable<String>.just(viewModel?.avatar_url ?? "")
            .asDriver(onErrorJustReturn: "").drive(onNext: { [weak self] urlString in
                guard let url = URL(string: urlString) else {return}
                self?.avatarImage.sd_setImage(with: url , completed: nil)
            }).disposed(by: disposeBag)
    }
    
}
