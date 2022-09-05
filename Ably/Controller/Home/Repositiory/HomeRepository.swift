//
//  HomeRepository.swift
//  Ably
//
//  Created by 김희진 on 2022/09/05.
//

import Foundation
import RxSwift
import RxCocoa

class HomeRepository {
    let disposdBag = DisposeBag()
    
    func getHomeData() -> Single<HomeModel> {
        let resource = Resource<HomeModel>(url: URL(string: AblyKey.urlString + AblyRequest.Home.home)!)
        
        return Single.create { single in
            URLRequest.load(resource: resource)
                .subscribe(onNext: { data in
                    single(.success(data))
                }).disposed(by: self.disposdBag)
            return Disposables.create {}
        }
    }
    
    func getHomeMoreGoods(params: Int) -> Single<HomeModelOnlyGoods> {
        let resource = Resource<HomeModelOnlyGoods>(url: URL(string: AblyKey.urlString + AblyRequest.Home.goods + "\(params)")!)
        
        return Single.create { single in
            URLRequest.load(resource: resource)
                .subscribe(onNext: { data in
                    single(.success(data))
                }).disposed(by: self.disposdBag)
            return Disposables.create {}
        }
    }
}
