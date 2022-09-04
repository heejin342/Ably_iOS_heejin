//
//  HomeViewModel.swift
//  Ably
//
//  Created by 김희진 on 2022/09/03.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {


    let resource = Resource<HomeModel>(url: URL(string: "http://d2bab9i9pr8lds.cloudfront.net/api/home")!)
    let disposeBag = DisposeBag()
    
    let responseData = BehaviorRelay<HomeModel?>(value: nil)
    
    var responseBannerData = BehaviorRelay<[Banners]>(value: [])
    var responseDatawithLike = BehaviorRelay<[GoodsViewModel]>(value: [])
    
    var isLoading = false
    var isFinish = false
    
    let realmManager = LikeListRealmManager.shared
    
    init() {
        populateData()
    }
        
    func populateData(){
        URLRequest.load(resource: resource)
            .subscribe(onNext: { data in
                self.realmManager.realmFindByRange(firstId: data.goods.first?.id, lastId: data.goods.last?.id) { savedData in

                    let goodViewModel = data.goods.map { data -> GoodsViewModel in
                        if let likedData = savedData.first(where: { $0.id == data.id }) {
                            return GoodsViewModel(value: likedData)
                        }
                        return GoodsViewModel(id: data.id, name: data.name, image: data.image, actualPrice: data.actualPrice, price: data.price, isNew: data.isNew, sellCount: data.sellCount, isLike: false)
                    }
                    
                    self.responseDatawithLike.accept(goodViewModel)
                }
//                self.responseData.accept(data)
                self.responseBannerData.accept(data.banners)
             })
        .disposed(by: disposeBag)
    }
    
    func fetchMoreData(from lastId: Int, _ complete: @escaping ([IndexPath]) -> Void) {
        let resource2 = Resource<HomeModelOnlyGoods>(url: URL(string: "http://d2bab9i9pr8lds.cloudfront.net/api/home/goods?lastId=\(lastId)")!)
        
        URLRequest.load(resource: resource2)
            .subscribe(onNext: { data in

                if data.goods.isEmpty {
                    self.isLoading = false
                    self.isFinish = true
                    complete([])
                    
                } else {
                    self.realmManager.realmFindByRange(firstId: data.goods.first?.id, lastId: data.goods.last?.id) { savedData in
                        let goodViewModel = data.goods.map { data -> GoodsViewModel in
                            if let likedData = savedData.first(where: { $0.id == data.id }) {
                                return GoodsViewModel(value: likedData)
                            }
                            return GoodsViewModel(id: data.id, name: data.name, image: data.image, actualPrice: data.actualPrice, price: data.price, isNew: data.isNew, sellCount: data.sellCount, isLike: false)
                        }
                        
                        var beforedata = self.responseDatawithLike.value
                        var returnData: [IndexPath] = []

                        for (index,value) in goodViewModel.enumerated() {
                            beforedata.append(value)
                            returnData.append(IndexPath(row: lastId + index, section: 0))
                        }
                        self.responseDatawithLike.accept(beforedata)
                        self.isLoading = false
                        
                        complete(returnData)
                    }
                }
            })
        .disposed(by: disposeBag)
    }
}

