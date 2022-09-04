//
//  HomeViewModel.swift
//  Ably
//
//  Created by 김희진 on 2022/09/03.
//

import Foundation
import RxSwift
import RxCocoa
import Realm
import RealmSwift

class HomeViewModel {

    let realm = try! Realm()

    let resource = Resource<HomeModel>(url: URL(string: "http://d2bab9i9pr8lds.cloudfront.net/api/home")!)
    let disposeBag = DisposeBag()
    
    let responseData = BehaviorRelay<HomeModel?>(value: nil)
    var responseDatawithLike = BehaviorRelay<[GoodsViewModel]>(value: [])
    var savedLike: [GoodsViewModel] = []
    
    var isLoading = false
    var isFinish = false
    
//    let realmManeger = RealmManager.shared.a()
    
    init() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        populateData()
    }
        
    func populateData(){
        URLRequest.load(resource: resource)
            .subscribe(onNext: { data in
                self.realmFindByRange(firstId: data.goods.first?.id, lastId: data.goods.last?.id) { savedData in

                    let goodViewModel = data.goods.map { data -> GoodsViewModel in
                        if let likedData = savedData.first(where: { $0.id == data.id }) {
                            return GoodsViewModel(value: likedData)
                        }
                        return GoodsViewModel(id: data.id, name: data.name, image: data.image, actualPrice: data.actualPrice, price: data.price, isNew: data.isNew, sellCount: data.sellCount, isLike: false)
                    }
                    
                    self.responseDatawithLike.accept(goodViewModel)
                }
                self.responseData.accept(data)
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
                    self.realmFindByRange(firstId: data.goods.first?.id, lastId: data.goods.last?.id) { savedData in
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

extension HomeViewModel {
    func realmRead(_ complete: @escaping ([GoodsViewModel]) -> Void) {
        DispatchQueue.main.async {
            self.savedLike = Array(self.realm.objects(GoodsViewModel.self))
            complete(self.savedLike)
        }
    }
    
    func realmFindByRange(firstId: Int?, lastId: Int?, _ complete: @escaping ([GoodsViewModel]) -> Void) {
        if let fId = firstId, let lId = lastId {
            DispatchQueue.main.async {
                self.savedLike = Array(self.realm.objects(GoodsViewModel.self).filter("id >= %@ AND id <= %@", fId, lId))
                complete(self.savedLike)
            }
        } else {
            complete([])
        }
    }
    
    func realmUpdate(data: GoodsViewModel){
        try! realm.write {
            if data.isLike {
                realm.add(data)
            } else {
                let taskToDelete = realm.objects(GoodsViewModel.self).filter("id == %@", data.id)
                realm.delete(taskToDelete)
             }
        }
    }
    
    func realmDeleteSchema(){
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
                realmURL,
                realmURL.appendingPathExtension("lock"),
                realmURL.appendingPathExtension("note"),
                realmURL.appendingPathExtension("management")
            ]
        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
            } catch {}
        }
    }
}
