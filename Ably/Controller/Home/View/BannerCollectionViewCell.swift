//
//  BannerCollectionViewCell.swift
//  Ably
//
//  Created by 김희진 on 2022/09/02.
//

import Foundation
import UIKit

class BannerCollectionViewCell: UICollectionViewCell {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var pageLabel: UILabel = {
        let label = UILabel()
//        label.text = "\(currentIndex + 1)/\(imageArray.count)"
//        label.textColor = .grey60
//        label.font =  UIFont(name: Font.regular, size: 15)
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(pageLabel)
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        pageLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(20)
        }
    }

    func configure(banner: Banners) {
        pageLabel.text = "\(banner.id)"

        let _url = URL(string: banner.image)
        let data2 = try? Data(contentsOf: _url!)
                        
        imageView.image = UIImage(data: data2!)

    }
}
