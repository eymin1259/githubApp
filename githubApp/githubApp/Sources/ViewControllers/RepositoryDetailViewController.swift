//
//  RepositoryDetailViewController.swift
//  githubApp
//
//  Created by yongmin lee on 10/11/21.
//

import UIKit
import WebKit
import SDWebImage
import RxSwift
import RxCocoa

class RepositoryDetailViewController: BaseViewController {

    //MARK: properties
    var repoDetailViewModel : RepositoryDetailViewModel!
    var disposeBag = DisposeBag()
    
    //MARK: UI
    var repositoryLabel = UITextView()
    var descriptionLabel = UITextView()
    var avatarImage = UIImageView()
    var ownerLabel = UILabel()
    var ownerType = UILabel()
    var starImageView = UIImageView()
    var starCountLabel = UILabel()
    var forkImageView = UIImageView()
    var forkCountLabel = UILabel()
    var starButton = UIImageView()
    var dividerView = UIView()
    var webView = WKWebView()   //README.md webview
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup ui
        setupRepositoryLabel()
        setupDescriptionLabel()
        setupAvatarImage()
        setupOwnerLabel()
        setupOwnerType()
        setupStarView()
        setupForkView()
        setupStarButton()
        setupReadMe()
        setupViewController()
        // bind
        bind()
    }
    
    //MARK: methods
    func setupViewController() {
        view.backgroundColor = .white
        repoDetailViewModel.disposbag = self.disposeBag
        repoDetailViewModel.getRepositoryDetail()
        if isLoggedIn() {
            repoDetailViewModel.checkIsStarredRepository()
        }
    }
    
    func setupRepositoryLabel(){
        // repositoryLabel 설정
        repositoryLabel.font = .boldSystemFont(ofSize: 35)
        repositoryLabel.textColor = .black
        repositoryLabel.isUserInteractionEnabled = false
        repositoryLabel.translatesAutoresizingMaskIntoConstraints = false
        repositoryLabel.isScrollEnabled = false //auto height
        //  repositoryLabel layout 설정
        view.addSubview(repositoryLabel)
        repositoryLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        repositoryLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        repositoryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    }
    
    func setupDescriptionLabel() {
        
        descriptionLabel.font = .boldSystemFont(ofSize: 25)
        descriptionLabel.textColor = .systemGray3
        descriptionLabel.isUserInteractionEnabled = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.isScrollEnabled = false
        //  descriptionLabel layout 설정
        view.addSubview(descriptionLabel)
        descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: repositoryLabel.bottomAnchor, constant: 0).isActive = true
    }

    func setupAvatarImage() {
        avatarImage.contentMode = .scaleAspectFill
        avatarImage.clipsToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.backgroundColor = .systemGray6
        // avatarImage layout
        view.addSubview(avatarImage)
        avatarImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        avatarImage.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20).isActive = true
        avatarImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        avatarImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        avatarImage.layer.cornerRadius = 40
    }
    
    func setupOwnerLabel() {
        //  ownerLabel  설정
        ownerLabel.font = .boldSystemFont(ofSize: 25)
        ownerLabel.textColor = .black
        ownerLabel.lineBreakMode = .byTruncatingTail
        ownerLabel.translatesAutoresizingMaskIntoConstraints = false
        //  ownerLabel layout 설정
        view.addSubview(ownerLabel)
        ownerLabel.leftAnchor.constraint(equalTo: avatarImage.rightAnchor, constant: 30).isActive = true
        ownerLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        ownerLabel.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor, constant: -15).isActive = true
        
    }
    
    func setupOwnerType(){
        ownerType.font = .boldSystemFont(ofSize: 20)
        ownerType.textColor = .black
        ownerType.translatesAutoresizingMaskIntoConstraints = false
        // layout
        view.addSubview(ownerType)
        ownerType.leftAnchor.constraint(equalTo: avatarImage.rightAnchor, constant: 30).isActive = true
        ownerType.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        ownerType.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor, constant: 15).isActive = true
    }
    
    func setupStarView() {
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.contentMode = .scaleAspectFit
        starImageView.image = #imageLiteral(resourceName: "star")
        // starImageView layout
        view.addSubview(starImageView)
        starImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        starImageView.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 30).isActive = true
        starImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        starImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        starCountLabel.font = .systemFont(ofSize: 15)
        starCountLabel.textColor = .black
        starCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(starCountLabel)
        starCountLabel.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor).isActive = true
        starCountLabel.leftAnchor.constraint(equalTo: starImageView.rightAnchor, constant: 10).isActive = true
        
    }
    
    func setupForkView(){
        forkImageView.translatesAutoresizingMaskIntoConstraints = false
        forkImageView.contentMode = .scaleAspectFit
        forkImageView.image = #imageLiteral(resourceName: "fork")
        // forkImageView layout
        view.addSubview(forkImageView)
        forkImageView.leftAnchor.constraint(equalTo: starCountLabel.rightAnchor, constant: 20).isActive = true
        forkImageView.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor).isActive = true
        forkImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        forkImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        forkCountLabel.font = .systemFont(ofSize: 15)
        forkCountLabel.textColor = .black
        forkCountLabel.translatesAutoresizingMaskIntoConstraints = false
        // layout
        view.addSubview(forkCountLabel)
        forkCountLabel.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor).isActive = true
        forkCountLabel.leftAnchor.constraint(equalTo: forkImageView.rightAnchor, constant: 10).isActive = true
    }
    
    func setupStarButton(){
        // starButton 설정
        starButton.contentMode = .scaleAspectFit
        starButton.clipsToBounds = true
        starButton.translatesAutoresizingMaskIntoConstraints = false
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleClickedStarButton))
        tap.numberOfTapsRequired = 1
        starButton.addGestureRecognizer(tap)
        starButton.isUserInteractionEnabled = true
        
        // loginButton layout
        view.addSubview(starButton)
        starButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        starButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        starButton.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor).isActive = true
        starButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
    }
    
    func setupReadMe() {
        dividerView.backgroundColor = .systemGray4
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dividerView)
        dividerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        dividerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        dividerView.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 30).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: dividerView.bottomAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    //MARK: bind
    func bind(){
        //ViewModel bind
        // repositoryLabel
        repoDetailViewModel.nameSuject
            .asDriver(onErrorJustReturn: "").drive(repositoryLabel.rx.text).disposed(by: disposeBag)

        // descriptionLabel
        repoDetailViewModel.descriptionSuject
            .asDriver(onErrorJustReturn: "").drive(onNext: { [weak self] description in
                if description == "" {
                    self?.descriptionLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
                }
                else {
                    self?.descriptionLabel.text = description
                }
            }).disposed(by: disposeBag)

        // avatarImage
        repoDetailViewModel.ownerAvatarSuject
            .asDriver(onErrorJustReturn: "").drive(onNext: { [weak self] urlString in
                guard let url = URL(string: urlString) else {return}
                self?.avatarImage.sd_setImage(with: url , completed: nil)
            }).disposed(by: disposeBag)

        // ownerLabel
        repoDetailViewModel.ownerLoginSuject
            .asDriver(onErrorJustReturn: "").drive(ownerLabel.rx.text).disposed(by: disposeBag)

        // ownerType
        repoDetailViewModel.ownerTypeSuject
            .asDriver(onErrorJustReturn: "").drive(ownerType.rx.text).disposed(by: disposeBag)

        // starCountLabel
        repoDetailViewModel.starCountSuject
            .asDriver(onErrorJustReturn: 0).drive(onNext: { [weak self] starCount in
                self?.starCountLabel.text = "\(starCount)"
            }).disposed(by: disposeBag)

        // forkCountLabel
        repoDetailViewModel.forkCountSuject
            .asDriver(onErrorJustReturn: 0).drive(onNext: { [weak self] starCount in
                self?.forkCountLabel.text = "\(starCount)"
            }).disposed(by: disposeBag)

        // readme webView
        repoDetailViewModel.htmlSuject
            .asDriver(onErrorJustReturn: "").drive(onNext: { [weak self] urlString in
                guard let url = URL(string: urlString) else {return}
                self?.webView.load(URLRequest(url: url))
            }).disposed(by: disposeBag)
        
        // starButton image
        repoDetailViewModel.starSubject
            .subscribe(onNext: { [weak self] isStarred in
                if isStarred {
                    self?.starButton.image = #imageLiteral(resourceName: "star")
                }else {
                    self?.starButton.image = #imageLiteral(resourceName: "unStar")
                }
            }).disposed(by: disposeBag)
    }
    
    //MARK: actions
    @objc func handleClickedStarButton(){
        if isLoggedIn() {
            showLoading()
            repoDetailViewModel.toggleStar()
                .subscribe(onNext: { [weak self] starred in
                    self?.hideLoading()
                }).disposed(by: disposeBag)
        }
        else {
            showErrorToastMessage(message: "로그인 후 이용 가능합니다.")
        }
    }
}
