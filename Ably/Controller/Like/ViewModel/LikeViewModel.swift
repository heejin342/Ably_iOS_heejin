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
    
    var likeListArray = BehaviorRelay<[GoodsViewModel]>(value: [])
    var likeListisEmpty = BehaviorRelay<Bool>(value: true)
    
    let realmManager = LikeListRealmManager.shared

    func populateData(){
        realmManager.realmRead() { savedData in
            self.likeListArray.accept(savedData.reversed())
            self.likeListisEmpty.accept(savedData.isEmpty ? true : false)
        }
    }
}
