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
    
    init() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        populateData()
    }
    
    func populateData(){
        URLRequest.load(resource: resource)
            .subscribe(onNext: { data in

                self.realmRead() { savedData in
                    self.responseDatawithLike.accept(
                        data.goods.map { data -> GoodsViewModel in
                        var a: GoodsViewModel?
                        if savedData.count > 0 {
                            if savedData.contains(where: { $0.id == data.id }) {
                                a = GoodsViewModel(id: data.id, name: data.name, image: data.image, actualPrice: data.actualPrice, price: data.price, isNew: data.isNew, sellCount: data.sellCount, isLike: true)
                            } else {
                                a = GoodsViewModel(id: data.id, name: data.name, image: data.image, actualPrice: data.actualPrice, price: data.price, isNew: data.isNew, sellCount: data.sellCount, isLike: false)
                            }
                        } else {
                            a = GoodsViewModel(id: data.id, name: data.name, image: data.image, actualPrice: data.actualPrice, price: data.price, isNew: data.isNew, sellCount: data.sellCount, isLike: false)
                        }
                            
                        guard let a = a else {
                            return GoodsViewModel(id: 0, name: "", image: "", actualPrice: 0, price: 0, isNew: false, sellCount: 0, isLike: false)
                        }
                        return a
                    })
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
                    
                    self.realmRead { savedData in
                        let vm = data.goods.map { data -> GoodsViewModel in
                            var a: GoodsViewModel?
                            if savedData.contains(where: { $0.id == data.id }) {
                                a = GoodsViewModel(id: data.id, name: data.name, image: data.image, actualPrice: data.actualPrice, price: data.price, isNew: data.isNew, sellCount: data.sellCount, isLike: true)
                            } else {
                                a = GoodsViewModel(id: data.id, name: data.name, image: data.image, actualPrice: data.actualPrice, price: data.price, isNew: data.isNew, sellCount: data.sellCount, isLike: false)
                            }
                            guard let a = a else {
                                return GoodsViewModel(id: 0, name: "", image: "", actualPrice: 0, price: 0, isNew: false, sellCount: 0, isLike: false)
                            }
                            return a
                        }
                        
                        var beforedata = self.responseDatawithLike.value
                        for i in vm {
                            beforedata.append(i)
                        }
                        self.responseDatawithLike.accept(beforedata)
                        self.isLoading = false
                        
                        var returnData: [IndexPath] = []
                        for i in 0...9 {
                            returnData.append(IndexPath(row: lastId + i, section: 0))
                        }
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
