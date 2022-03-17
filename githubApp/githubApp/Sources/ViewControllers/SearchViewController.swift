//
//  SearchViewController.swift
//  githubApp
//
//  Created by yongmin lee on 10/9/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchViewController: BaseViewController {

    //MARK: properties
    var searchViewModel : RepositoryViewModel!
    var tableViewDataSource : RxTableViewSectionedReloadDataSource<RepositorySectionModel>!
    var disposeBag = DisposeBag()
    
    //MARK: UI
    var searchController = UISearchController(searchResultsController: nil)
    var tableView = UITableView()
    var searchStatusLabel = UILabel()
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup UI
        setupViewController()
        setupNotiObserver()
        setupSearchController()
        setupTableView()
        setupSearchStatusLabel()
        // bind action, viewmodel
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = false
        setupAuthButton()
    }

    //MARK: methods
    func setupViewController() {
        view.backgroundColor = .white
        // viewModel settung
        searchViewModel.disposeBag = disposeBag
        // get default repo list, query = hello world
        showLoading()
        searchViewModel.searchRepository(scrolled: false, query: "hello world")
    }
    
    func setupSearchStatusLabel() {
        // searchStatusLabel : 검색결과가 없음을 알려주는 텍스트
        searchStatusLabel.font = .systemFont(ofSize: 20)
        searchStatusLabel.textColor = .darkGray
        searchStatusLabel.text = "no search result"
        searchStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        searchStatusLabel.isHidden = true
        //  searchStatusLabel layout 설정
        view.addSubview(searchStatusLabel)
        searchStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setupSearchController() {
        // setupSearchController ui 설정
        navigationItem.title = "Repositories"
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "search"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func setupTableView(){
        // tableView layout 설정
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive =  true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.separatorStyle = .none
        // tableViewCell 등록
        tableView.register(RepoTableViewCell.self, forCellReuseIdentifier: RepoTableViewCell.ID)
    }
    
    //MARK: bind
    func bind() {
        // Action
        // searchController 입력이 시작될때 action
        searchController.searchBar
            .rx
            .textDidBeginEditing
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self ] in
                self?.hideLoading()
                self?.searchStatusLabel.isHidden = true
                self?.searchController.searchBar.text = "" // searchBar 텍스트 초기화
            })
            .disposed(by: disposeBag)
        
        // searchController 검색 클릭시 action
        searchController.searchBar
            .rx
            .searchButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self ] in
                self?.showLoading()
                self?.searchController.searchBar.endEditing(true)
                let query = self?.searchController.searchBar.text ?? ""
                // 검색어로 repository 검색
                self?.searchViewModel.searchRepository(scrolled: false, query: query)
                    
            })
            .disposed(by: disposeBag)
        
        // tableView에서 Row 선택시 action
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Repository.self))
            .bind { [weak self] indexPath, model in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                if let logged = self?.isLoggedIn(),
                   logged == true {
                    self?.tableView.isHidden = true
                    // Repository Detail 보여주기
//                    let detailViewController = RepositoryDetailViewController()
//                    detailViewController.repoDetailViewModel = RepositoryDetailViewModel(fullName: model.full_name)
                    let detailViewController = self?.DIContainer.resolve(RepositoryDetailViewController.self, argument: model.full_name)
                    self?.navigationController?.pushViewController(detailViewController!, animated: true)
                }
                else {
                    self?.showErrorToastMessage(message: "로그인이 되어있지 않습니다!")
                }
            }
            .disposed(by: disposeBag)
        
        // tableView 스크롤시 action
        tableView.rx
            .didScroll
            .subscribe(onNext: { [weak self] in
                // end editing
                self?.searchController.searchBar.endEditing(true)
                self?.searchController.searchBar.resignFirstResponder()
                // 스크롤하여 하단까지 도착했는지 검사
                guard let offsetY = self?.tableView.contentOffset.y else {return}
                guard let contentHeight = self?.tableView.contentSize.height else {return}
                guard let framHeight = self?.tableView.frame.height else {return}
                let isBottom = offsetY >=  contentHeight - framHeight - 180
                if isBottom && self?.searchViewModel.isSearching == false && self?.searchViewModel.isEnd == false { // 하단까지 스크롤 했다면
                    self?.showLoading()
                    // 무한 스크롤
                    self?.searchViewModel.searchRepository(scrolled: true)
                }
            })  .disposed(by: disposeBag)
        
        // ViewModel
        // 검색결과에 따라 결과 없음 메세지 hidden 여부 바인딩
        searchViewModel.repositoriesSubect
            .subscribe(onNext: { [weak self] SectionModels in
                self?.hideLoading()
                let repoCount = SectionModels.first?.items.count ?? 0
                if repoCount == 0 {
                    self?.searchStatusLabel.text = "no search result"
                    self?.searchStatusLabel.isHidden = false
                }
                else {
                    self?.searchStatusLabel.isHidden = true
                }
            }).disposed(by: disposeBag)
        
        // tableView
        // datasource 정의
        let tableViewDataSource = RxTableViewSectionedReloadDataSource<RepositorySectionModel>(configureCell: { [weak self] datasource, tableview, indexpath, item in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: RepoTableViewCell.ID, for: indexpath) as? RepoTableViewCell else {return RepoTableViewCell()}
            cell.viewModel = item
            cell.disposeBag = self?.disposeBag
            // setup UI
            cell.setupOwnerLabel()
            cell.setupRepoNameLabel()
            cell.setupAvatarImage()
            cell.setupArrowLabel()
            // binding
            cell.bind()
            return cell
        })
        // tableView binding
        searchViewModel.repositoriesSubect
            .bind(to: tableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: disposeBag)
    }

    //MARK: actions
    override func didClickedLoginButton() {
        super.didClickedLoginButton()
        searchViewModel.login()
    }
    
    override func didClickedLoutOutButton() {
        super.didClickedLoutOutButton()
        searchViewModel.logout()
    }
    
    override func handleDidSaveAccessToken() {
        super.handleDidSaveAccessToken()
        showToastMessage(message: "로그인 성공!")
    }
    
    override func handleFailSaveAccessToken() {
        super.handleFailSaveAccessToken()
        showErrorToastMessage(message: "로그인 실패, 잠시후 다시 시도해주세요.")
    }

}
