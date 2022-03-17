//
//  ProfileViewController.swift
//  githubApp
//
//  Created by yongmin lee on 10/9/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ProfileViewController: BaseViewController {
    
    //MARK: properties
    var profileViewModel : RepositoryViewModel!
    var disposeBag = DisposeBag()
    
    //MARK: UI
    var loginLabel = UILabel()
    var loginButton = UIImageView()
    var headerView = ProfileHeaderView()
    var tableView = UITableView()
    var emptyRepoLabel = UILabel()
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup UI
        setupViewController()
        setupNotiObserver()
        setupHeaderView()
        setupTableView()
        setupEmptyRepoLabel()
        setupLoginView()
        //bind action, viewModel
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAuthButton()
        // 로그인상태이면
        if isLoggedIn() {
            // header update
            headerView.viewModel = profileViewModel.getOwnerInfo()
            headerView.bind()
            // repo update
            profileViewModel.getMyRepositories(scrolled: false)
            setLoginStatusView()
        }
        // 로그아웃 상태
        else {
            setLogoutStatusView()
        }
    }
   
  
    // MARK: methods
    func setupViewController() {
        view.backgroundColor = .white
        navigationItem.title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
        // viewModel
        profileViewModel.disposeBag = self.disposeBag
    }
    
    func setupEmptyRepoLabel(){
        // emptyRepoLabel : 나의 레포지토리가 없음을 알려주는 텍스트
        emptyRepoLabel.font = .systemFont(ofSize: 20)
        emptyRepoLabel.textColor = .darkGray
        emptyRepoLabel.text = "no repository"
        emptyRepoLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyRepoLabel.isHidden = true
        //  emptySearchResultLabel layout 설정
        view.addSubview(emptyRepoLabel)
        emptyRepoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyRepoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setupHeaderView() {
        // headerView layout
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        // setup headerView
        headerView.setupAvatarImage()
        headerView.setupLoginLabel()
        headerView.setupFollowerLabel()
        headerView.disposeBag = self.disposeBag
    }

    
    func setupTableView(){
        // tableView layout
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive =  true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.separatorStyle = .none
        // tableViewCell 등록
        tableView.register(RepoTableViewCell.self, forCellReuseIdentifier: RepoTableViewCell.ID)
    }
    
    func setupLoginView(){
        // loginLabel 설정
        loginLabel.font = .boldSystemFont(ofSize: 20)
        loginLabel.textColor = .darkGray
        loginLabel.text = "로그인이 필요합니다."
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        //  loginLabel layout 설정
        view.addSubview(loginLabel)
        loginLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true

        // loginButton 설정
        loginButton.contentMode = .scaleAspectFit
        loginButton.clipsToBounds = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.image = #imageLiteral(resourceName: "loginIcon")
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didClickedLoginButton))
        tap.numberOfTapsRequired = 1
        loginButton.addGestureRecognizer(tap)
        loginButton.isUserInteractionEnabled = true
        // loginButton layout
        view.addSubview(loginButton)
        loginButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        loginButton.layer.cornerRadius = 30
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
    }
    
    func setLoginStatusView(){
        // 로그인 상태일때의 보여줄 view 설정
        tableView.isHidden = false
        headerView.isHidden = false
        loginLabel.isHidden = true
        loginButton.isHidden = true
        emptyRepoLabel.isHidden = false
    }
    
    func setLogoutStatusView(){
        // 로그아웃 상태일때의 보여줄 view 설정
        tableView.isHidden = true
        headerView.isHidden = true
        loginLabel.isHidden = false
        loginButton.isHidden = false
        emptyRepoLabel.isHidden = true
    }
    
    //MARK: bind
    func bind() {
        
        //Action
        // tableView에서 Row 선택시 action
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Repository.self))
            .bind { [weak self] indexPath, model in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.tableView.isHidden = true
                // Repository Detail 보여주기
                let detailViewController = self?.DIContainer.resolve(RepositoryDetailViewController.self, argument: model.full_name)
                self?.navigationController?.pushViewController(detailViewController!, animated: true)
            }
            .disposed(by: disposeBag)
        
        // tableView 스크롤시 action
        tableView.rx
            .didScroll
            .subscribe(onNext: { [weak self] in
                // 스크롤하여 하단까지 도착했는지 검사
                guard let offsetY = self?.tableView.contentOffset.y else {return}
                guard let contentHeight = self?.tableView.contentSize.height else {return}
                guard let framHeight = self?.tableView.frame.height else {return}
                let isBottom = offsetY >=  contentHeight - framHeight - 90
                if isBottom && self?.profileViewModel.isSearching == false && self?.profileViewModel.isEnd == false { // 하단까지 스크롤 했다면
                    // 무한 스크롤
                    self?.profileViewModel.getMyRepositories(scrolled: true)
                }
            })  .disposed(by: disposeBag)
        
        //ViewModel
        // 나의 레포지토리 리스트 정보에 따라 emptyRepoLabel hidden 설정
        profileViewModel.repositoriesSubect
            .subscribe(onNext: { [weak self] SectionModels in
                let repoCount = SectionModels.first?.items.count ?? 0
                if repoCount == 0 {
                    self?.emptyRepoLabel.isHidden = false
                }
                else {
                    self?.emptyRepoLabel.isHidden = true
                }
            }).disposed(by: disposeBag)
        
        // tableView
        // datasource 정의
        let tableViewDataSource = RxTableViewSectionedReloadDataSource<RepositorySectionModel>(configureCell: { [weak self] datasource, tableview, indexpath, item in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: RepoTableViewCell.ID, for: indexpath) as? RepoTableViewCell else {return RepoTableViewCell()}
            cell.viewModel = item
            cell.disposeBag = self?.disposeBag
            cell.setupOwnerLabel()
            cell.setupRepoNameLabel()
            cell.setupAvatarImage()
            cell.setupArrowLabel()
            cell.bind()
            return cell
        })
        // tableView binding
        profileViewModel.repositoriesSubect
            .bind(to: tableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: disposeBag)
    }
    
    //MARK: actions
    override func didClickedLoginButton() {
        super.didClickedLoginButton()
        profileViewModel.login()
    }
    
    override func didClickedLoutOutButton() {
        super.didClickedLoutOutButton()
        profileViewModel.logout()
        setLogoutStatusView()
    }
    
    override func handleDidSaveAccessToken() {
        super.handleDidSaveAccessToken()
        //header update
        headerView.viewModel = profileViewModel.getOwnerInfo()
        headerView.bind()
        // repo list update
        profileViewModel.getMyRepositories(scrolled: false)
        setLoginStatusView()
    }
}
