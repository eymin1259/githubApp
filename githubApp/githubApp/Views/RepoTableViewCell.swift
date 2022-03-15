//
//  RepoTableViewCell.swift
//  githubApp
//
//  Created by yongmin lee on 10/10/21.
//

import UIKit
import SDWebImage
import RxSwift
import RxCocoa

class RepoTableViewCell: UITableViewCell {

    //MARK: properties
    var viewModel : Repository?
    var disposeBag : DisposeBag!
    static let ID = "RepoTableViewCell"
    
    //MARK: UI
    var ownerLabel = UILabel()
    var repoNameLabel = UILabel()
    var avatarImage = UIImageView()
    var arrowLabel = UILabel()

    // MARK: life cycle
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTableViewCell()         
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    //MARK: methods
    func setupTableViewCell(){
        // ui setup
        backgroundColor = .white
        heightAnchor.constraint(equalToConstant: 90).isActive = true
    }
    
    func setupOwnerLabel(){
        // ownerLabel 속성 설정
        ownerLabel.font = .systemFont(ofSize: 15)
        ownerLabel.textColor = .darkGray
        ownerLabel.translatesAutoresizingMaskIntoConstraints = false
        //  ownerLabel layout 설정
        addSubview(ownerLabel)
        ownerLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15).isActive = true
        ownerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 130).isActive = true
        ownerLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -70).isActive = true
    }
    
    func setupRepoNameLabel(){
        // repoNameLabel 속성 설정
        repoNameLabel.font = .boldSystemFont(ofSize: 20)
        repoNameLabel.translatesAutoresizingMaskIntoConstraints = false
        //  repoNameLabel layout 설정
        addSubview(repoNameLabel)
        repoNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15).isActive = true
        repoNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 130).isActive = true
        repoNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -70).isActive = true
    }
    
    func setupArrowLabel() {
        // arrowLabel 속성 설정
        arrowLabel.font = .boldSystemFont(ofSize: 20)
        arrowLabel.textColor = .darkGray
        arrowLabel.text = ">"
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        //  arrowLabel layout 설정
        addSubview(arrowLabel)
        arrowLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        arrowLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        
    }
    
    func setupAvatarImage() {
        // avatarImage 속성 설정
        avatarImage.contentMode = .scaleAspectFill
        avatarImage.clipsToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.backgroundColor = .systemGray6
        // avatarImage layout
        addSubview(avatarImage)
        avatarImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        avatarImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        avatarImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        avatarImage.layer.cornerRadius = 30
        avatarImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
    }
    
    //MARK: bind
    func bind() {
        // ViewModel binding
        // ownerLabel
        Observable<String>.just(viewModel?.owner.login ?? "")
            .asDriver(onErrorJustReturn: "").drive(ownerLabel.rx.text).disposed(by: disposeBag)
        // repoNameLabel
        Observable<String>.just(viewModel?.name ?? "")
            .asDriver(onErrorJustReturn: "").drive(repoNameLabel.rx.text).disposed(by: disposeBag)
        // avatarImage
        Observable<String>.just(viewModel?.owner.avatar_url ?? "")
            .asDriver(onErrorJustReturn: "").drive(onNext: { [weak self] urlString in
                guard let url = URL(string: urlString) else {return}
                self?.avatarImage.sd_setImage(with: url , completed: nil)
            }).disposed(by: disposeBag)
    }
}
