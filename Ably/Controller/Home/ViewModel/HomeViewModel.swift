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


    let disposeBag = DisposeBag()
    
    let responseData = BehaviorRelay<HomeModel?>(value: nil)
    
    var responseBannerData = BehaviorRelay<[Banners]>(value: [])
    var responseDatawithLike = BehaviorRelay<[GoodsViewModel]>(value: [])
    
    var isLoading = false
    var isFinish = false
    var isFirst = true

    let useCase = HomeUseCase()
    
    let realmManager = LikeListRealmManager.shared
    
    init() {
        populateData()
    }
        
    func populateData(){
        
        useCase.getHomeData()
            .subscribe(onNext: { data in
                self.useCase.getLikedData(firstId: data.goods.first?.id, lastId: data.goods.last?.id, data: data.goods) { returnData in
                    
                    self.responseDatawithLike.accept(returnData)
                    self.responseBannerData.accept(data.banners)
                }
            })
        .disposed(by: disposeBag)
    }
    
    func fetchMoreData(from lastId: Int, _ complete: @escaping ([IndexPath]) -> Void) {
        
        useCase.getMoreGoodData(param: lastId)
            .subscribe(onNext: { data in
                
                if data.goods.isEmpty {
                    self.isLoading = false
                    self.isFinish = true
                    complete([])
                } else {
                    self.useCase.getLikedData(firstId: data.goods.first?.id, lastId: data.goods.last?.id, data: data.goods) { returnData in
                        
                        var beforedata = self.responseDatawithLike.value
                        var updateIndexPath: [IndexPath] = []

                        for (index,value) in returnData.enumerated() {
                            beforedata.append(value)
                            updateIndexPath.append(IndexPath(row: lastId + index, section: 0))
                        }
                        self.responseDatawithLike.accept(beforedata)
                        self.isLoading = false

                        complete(updateIndexPath)
                    }
                }
            })
        .disposed(by: disposeBag)
    }
}

