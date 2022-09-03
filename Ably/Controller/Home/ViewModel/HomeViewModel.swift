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
}

extension HomeViewModel {
    func realmRead(_ complete: @escaping ([GoodsViewModel]) -> Void) {
        DispatchQueue.main.async {
            self.savedLike = Array(self.realm.objects(GoodsViewModel.self))
            complete(self.savedLike)
        }
    }
    
    func realmUpdate(at item: Int, data: GoodsViewModel){
        let taskToUpdate = self.responseDatawithLike.value[item]
        try! realm.write {
            if taskToUpdate.isLike { // 안좋아요에서 좋아요 됨
                realm.add(taskToUpdate)
            } else { // 좋아요에서 안좋아요로 됨
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
