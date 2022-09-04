//
//  LikeViewModel.swift
//  Ably
//
//  Created by 김희진 on 2022/09/04.
//

import Foundation
import RxSwift
import RxCocoa
import Realm
import RealmSwift

class LikeViewModel {

    let realm = try! Realm()
    var likeListArray = BehaviorRelay<[GoodsViewModel]>(value: [])
    var likeListisEmpty = BehaviorRelay<Bool>(value: true)

    func populateData(){
        self.realmRead() { savedData in
            self.likeListArray.accept(savedData)
            self.likeListisEmpty.accept(savedData.isEmpty ? true : false)
        }
    }
}

extension LikeViewModel {
    func realmRead(_ complete: @escaping ([GoodsViewModel]) -> Void) {
        DispatchQueue.main.async {
            complete(Array(self.realm.objects(GoodsViewModel.self)))
        }
    }
}
