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

    static var estimateCellH: CGFloat { 130.0 }
    
    let disposeBag = DisposeBag()
    var viewModel = HomeViewModel()
        
    lazy var contentCollectionView = HomeView().makeCollectionView()

    private let refresher = UIRefreshControl()

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
        contentCollectionView.refreshControl?.beginRefreshing()

        viewModel.populateData()
        
        contentCollectionView.refreshControl?.endRefreshing()
    }
    
    func bindUI(_ viewModel: HomeViewModel) {
        viewModel.responseDatawithLike
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { data in
                self.contentCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func changeButtonUI(sender: GoodsViewModel) {
        var beforeData = viewModel.responseDatawithLike.value
        beforeData = beforeData.map {
            if $0.id == sender.id {
                return GoodsViewModel(id: $0.id, name: $0.name, image: $0.image, actualPrice: $0.actualPrice, price: $0.price, isNew: $0.isNew, sellCount: $0.sellCount, isLike: !$0.isLike)
            } else {
                return GoodsViewModel(id: $0.id, name: $0.name, image: $0.image, actualPrice: $0.actualPrice, price: $0.price, isNew: $0.isNew, sellCount: $0.sellCount, isLike: $0.isLike)
            }
        }
        viewModel.responseDatawithLike.accept(beforeData)
        
        let index = beforeData.firstIndex(where: { $0.id == sender.id})
        guard let row = index else {return}
//        contentCollectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
        contentCollectionView.reloadData()
        viewModel.realmUpdate(at: row, data: sender)
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

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BannerView.Id , for: indexPath) as? BannerView else { return UICollectionReusableView() }

        if let data = viewModel.responseData.value?.banners {
            header.prepare(banners: data)
        }
        
        return header
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: .zero, left: .zero, bottom: 52, right: .zero)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: HomeViewController.estimateCellH)
    }
}
