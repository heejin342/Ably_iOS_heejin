//
//  ViewController.swift
//  Ably
//
//  Created by 김희진 on 2022/09/02.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var viewModel = HomeViewModel()
    
    lazy var contentCollectionView = HomeView().makeCollectionView()
    let refresher = UIRefreshControl()
    var loadingView: LoadingView?
    var bannerView: BannerView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI(viewModel)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.addSubview(contentCollectionView)
        contentCollectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "홈"
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        contentCollectionView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        viewModel.isFinish = false
        contentCollectionView.refreshControl?.beginRefreshing()
        viewModel.populateData()
        contentCollectionView.refreshControl?.endRefreshing()
    }
    
    func bindUI(_ viewModel: HomeViewModel) {
        viewModel.responseDatawithLike
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { data in
                if data.count == 10 {
                    self.contentCollectionView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func changeButtonUI(sender: GoodsViewModel) {
        var beforeData = viewModel.responseDatawithLike.value
        let newData = GoodsViewModel(value: sender)
        
        beforeData = beforeData.map {
            if $0.id == sender.id {
                newData.isLike = !sender.isLike
                return newData
            }
            
            return $0
        }
        
        viewModel.responseDatawithLike.accept(beforeData)
        contentCollectionView.reloadData()
        viewModel.realmUpdate(data: newData)
    }
    
    func loadMoreData() {
        if !viewModel.isLoading {
            viewModel.isLoading = true
            self.viewModel.fetchMoreData(from: self.viewModel.responseDatawithLike.value.last?.id ?? -1) { indexArr in
                if !indexArr.isEmpty {
                    DispatchQueue.main.async {
                        self.contentCollectionView.insertItems(at: indexArr)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.loadingView?.loadingIndicatorView.stopAnimating()
                    }
                }
            }
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let cellData = viewModel.responseDatawithLike.value

        return cellData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.Id, for: indexPath) as? ItemCollectionViewCell else { return UICollectionViewCell() }

        let cellData = viewModel.responseDatawithLike.value[indexPath.row]
        cell.configure(data: cellData)

        cell.onClick = { cellData in
            if let data = cellData {
                self.changeButtonUI(sender: data)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BannerView.Id , for: indexPath) as? BannerView else { return UICollectionReusableView() }
            
            bannerView = header
            if let data = viewModel.responseData.value?.banners {
                if !data.isEmpty {
                    var newDataArray = data
                    newDataArray.insert(data[data.count-1], at: 0)
                    newDataArray.append(data[0])
                    header.prepare(banners: newDataArray)
                }
            }
            return header
            
        } else if kind == UICollectionView.elementKindSectionFooter {

            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: LoadingView.Id , for: indexPath) as? LoadingView else { return UICollectionReusableView() }
            loadingView = footer
            return footer
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if viewModel.isLoading {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.frame.width, height: 55)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter && !viewModel.isFinish{
            self.loadingView?.loadingIndicatorView.startAnimating()
        } else if elementKind == UICollectionView.elementKindSectionHeader {
            self.bannerView?.initTimer()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            self.loadingView?.loadingIndicatorView.stopAnimating()
        } else if elementKind == UICollectionView.elementKindSectionHeader {
            self.bannerView?.timer?.invalidate()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !viewModel.isFinish {
            if indexPath.row == viewModel.responseDatawithLike.value.count - 2 && !viewModel.isLoading {
                loadMoreData()
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 130)
    }
}
