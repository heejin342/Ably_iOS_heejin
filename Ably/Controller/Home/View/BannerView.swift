//
//  BannerView.swift
//  Ably
//
//  Created by 김희진 on 2022/09/02.
//

import UIKit
import RxCocoa
import RxSwift

class BannerView: UICollectionReusableView {
    
    var currentIndex = 0
    var imageArray: [Banners] = []
    private let disposeBag = DisposeBag()
    
    private lazy var sliderCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.estimatedItemSize = .zero
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.isPagingEnabled = true
        view.backgroundColor = .black
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .white
        view.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: BannerCollectionViewCell.Id)
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        [sliderCollectionView].forEach{ addSubview($0) }
        sliderCollectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
//        sliderCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: [.centeredVertically, .centeredHorizontally], animated: true)
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func prepare(banners: [Banners]) {
        imageArray = banners
        sliderCollectionView.reloadData()
    }
}

extension BannerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.Id, for: indexPath) as! BannerCollectionViewCell
        let data = imageArray[indexPath.row]
        
        cell.configure(banner: data)
                
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / sliderCollectionView.frame.size.width)
//        pageLabel.text = "\(currentIndex + 1)/\(imageArray.count)"
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 0
    }
}
